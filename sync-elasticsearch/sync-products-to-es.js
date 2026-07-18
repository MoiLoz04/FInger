    /**
     * sync-products-to-es.js
     * ------------------------------------------------------------
     * Sincroniza la tabla `products` de Supabase con un índice de
     * Elasticsearch llamado "products". Pensado para correrse:
     *   - Manualmente: node sync-products-to-es.js
     *   - Como cron job / Edge Function programada (recomendado: cada 5 min,
     *     o disparado por un webhook de Supabase en INSERT/UPDATE de products)
     *
     * Variables de entorno requeridas (.env):
     *   SUPABASE_URL=
     *   SUPABASE_SERVICE_ROLE_KEY=   (service role, NO la anon key)
     *   ELASTICSEARCH_URL=           (ej: http://localhost:9200 o Elastic Cloud endpoint)
     *   ELASTICSEARCH_API_KEY=       (si usas Elastic Cloud)
     * ------------------------------------------------------------
     */

    import { createClient } from "@supabase/supabase-js";
    import { Client as ESClient } from '@elastic/elasticsearch'; //  CORRECTO
    //import { Client as ESClient } from "@elasticsearch/elasticsearch";
    import fs from "fs";
    import "dotenv/config";

    const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_ROLE_KEY
    );

    const es = new ESClient({
    node: process.env.ELASTICSEARCH_URL,
    auth: process.env.ELASTICSEARCH_API_KEY
        ? { apiKey: process.env.ELASTICSEARCH_API_KEY }
        : undefined,
    });

    const INDEX_NAME = "products";

    async function ensureIndex() {
    const exists = await es.indices.exists({ index: INDEX_NAME });
    if (!exists) {
        const mapping = JSON.parse(
        fs.readFileSync("./products-index-mapping.json", "utf-8")
        );
        await es.indices.create({ index: INDEX_NAME, body: mapping });
        console.log(`✅ Índice "${INDEX_NAME}" creado.`);
    } else {
        console.log(`ℹ️ Índice "${INDEX_NAME}" ya existe.`);
    }
    }

    async function syncProducts() {
    const { data: products, error } = await supabase
        .from("products")
        .select("*")
        .eq("activo", true);

    if (error) throw error;

    if (!products.length) {
        console.log("No hay productos activos para sincronizar.");
        return;
    }

    const body = products.flatMap((p) => [
        { index: { _index: INDEX_NAME, _id: p.id } },
        p,
    ]);

    const bulkResponse = await es.bulk({ refresh: true, body });

    if (bulkResponse.errors) {
        const erroredDocuments = [];
        bulkResponse.items.forEach((action, i) => {
        const operation = Object.keys(action)[0];
        if (action[operation].error) {
            erroredDocuments.push({
            status: action[operation].status,
            error: action[operation].error,
            document: body[i * 2 + 1],
            });
        }
        });
        console.error("❌ Errores en bulk insert:", erroredDocuments);
    } else {
        console.log(`✅ ${products.length} productos sincronizados con Elasticsearch.`);
    }
    }

    async function main() {
    await ensureIndex();
    await syncProducts();
    }

    main().catch((err) => {
    console.error("Error en sincronización:", err);
    process.exit(1);
    });