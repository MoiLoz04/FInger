export default function Privacidad() {
  return (
    <div className="max-w-3xl mx-auto px-4 lg:px-6 py-12 prose">
      <h1 className="font-display text-2xl font-semibold text-graphite mb-4">
        Aviso de Privacidad
      </h1>
      <p className="text-steel text-sm mb-4">
        Última actualización: {new Date().toLocaleDateString("es-MX")}
      </p>
      <p className="text-sm text-graphite/80 mb-4">
        IndustrIA B2B, con domicilio en Parque Industrial Querétaro, Bernardo
        Quintana 1500, es responsable del tratamiento de sus datos personales
        conforme a la Ley Federal de Protección de Datos Personales en
        Posesión de los Particulares (LFPDPPP).
      </p>
      <h2 className="font-display font-semibold text-graphite mt-6 mb-2">
        Datos que recabamos
      </h2>
      <p className="text-sm text-graphite/80 mb-4">
        Nombre, correo electrónico, teléfono e información de la empresa
        proporcionados al registrarse, cotizar productos o contactarnos.
      </p>
      <h2 className="font-display font-semibold text-graphite mt-6 mb-2">
        Finalidad
      </h2>
      <p className="text-sm text-graphite/80 mb-4">
        Procesar cotizaciones, dar seguimiento comercial y responder
        solicitudes de contacto.
      </p>
      <h2 className="font-display font-semibold text-graphite mt-6 mb-2">
        Derechos ARCO
      </h2>
      <p className="text-sm text-graphite/80">
        Puede ejercer sus derechos de Acceso, Rectificación, Cancelación u
        Oposición escribiendo a ventas@industria-b2b.mx.
      </p>
    </div>
  );
}