let graficoUC = null;
let pensumCache = null;

// 1) Cargar pensum.json
fetch("pensum.json")
  .then(res => res.json())
  .then(data => {
    pensumCache = data;
    const contenedor = document.getElementById("contenedor");

    data.forEach((materia, index) => {
      const div = document.createElement("div");
      div.className = "materia";

      const codigoVisible = materia.codigo_oficial || materia.codigo_sistema;

      div.innerHTML = `
        <label>
          <input type="checkbox" id="m${index}">
          ${codigoVisible} - ${materia.nombre}
        </label>
      `;

      contenedor.appendChild(div);
    });
  });

// 2) Evaluar materias sin API
function enviar() {
  if (!pensumCache) return;

  const aprobadas = [];
  pensumCache.forEach((m, i) => {
    const check = document.getElementById("m" + i);
    if (check.checked) {
      aprobadas.push(m.codigo_oficial || m.codigo_sistema);
    }
  });

  const detalle = pensumCache.map(m => {
    const codigo = m.codigo_oficial || m.codigo_sistema;
    const estado = aprobadas.includes(codigo) ? "aprobada" : "no_aprobada";
    return { ...m, codigo, estado };
  });

  const aprobadasCodigos = detalle
    .filter(m => m.estado === "aprobada")
    .map(m => m.codigo);

  detalle.forEach(m => {
    if (m.estado === "aprobada") return;

    if (!m.requisitos || m.requisitos.length === 0) {
      m.estado = "no_aprobada";
    } else if (m.requisitos.every(r => aprobadasCodigos.includes(r))) {
      m.estado = "disponible";
    } else {
      m.estado = "bloqueada";
    }
  });

  const resumen = {
    aprobadas: aprobadas.length,
    uc_acumuladas: detalle
      .filter(m => m.estado === "aprobada")
      .reduce((sum, m) => sum + (m.uc || 0), 0),
    total_materias: detalle.length
  };

  construirDashboard({ resumen, detalle });
}

// 3) Construir dashboard
function construirDashboard({ resumen, detalle }) {
  document.getElementById("res-aprobadas").textContent = resumen.aprobadas;
  document.getElementById("res-uc").textContent = resumen.uc_acumuladas;
  document.getElementById("res-total").textContent = resumen.total_materias;

  const ucTotales = detalle.reduce((sum, m) => sum + (m.uc || 0), 0);
  const ucRestantes = ucTotales - resumen.uc_acumuladas;

  const ctx = document.getElementById("graficoUC").getContext("2d");
  if (graficoUC) graficoUC.destroy();

  graficoUC = new Chart(ctx, {
    type: "doughnut",
    data: {
      labels: ["UC aprobadas", "UC restantes"],
      datasets: [{
        data: [resumen.uc_acumuladas, ucRestantes],
        backgroundColor: ["#4caf50", "#cccccc"]
      }]
    },
    options: { plugins: { legend: { position: "bottom" } } }
  });

  const lista = document.getElementById("lista-materias");
  lista.innerHTML = "";

  detalle.forEach(m => {
    const card = document.createElement("div");
    card.className = "card-materia estado-" + m.estado;

    const requisitosTexto = m.requisitos?.length
      ? "Requisitos: " + m.requisitos.join(", ")
      : "Sin requisitos";

    card.innerHTML = `
      <div>
        <span class="codigo">${m.codigo}</span>
        <span>${m.nombre}</span>
        <span class="semestre">[Semestre ${m.semestre}]</span>
        <span class="estado-tag ${m.estado}">${m.estado.replace("_", " ")}</span>
      </div>
      <div class="requisitos">${requisitosTexto}</div>
    `;

    lista.appendChild(card);
  });
}
