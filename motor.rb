require "json"

class MotorAcademico
  attr_reader :pensum, :estados

  # ---------------------------------------------------------
  # CONSTRUCTOR: recibe pensum y estados desde la API
  # ---------------------------------------------------------
  def initialize(pensum, estados)
    @pensum = pensum
    @estados = estados
  end

  # ---------------------------------------------------------
  # BUSCAR MATERIA POR CÓDIGO (oficial o sistema)
  # ---------------------------------------------------------
  def buscar(codigo)
    @pensum.find do |m|
      m[:codigo_sistema] == codigo || m[:codigo_oficial] == codigo
    end
  end

  # ---------------------------------------------------------
  # OBTENER REQUISITOS DE UNA MATERIA
  # ---------------------------------------------------------
  def requisitos(codigo)
    materia = buscar(codigo)
    return [] unless materia
    materia[:requisitos] || []
  end

  # ---------------------------------------------------------
  # VALIDAR SI UN ESTUDIANTE PUEDE CURSAR UNA MATERIA
  # ---------------------------------------------------------
  def puede_cursar?(codigo, aprobadas)
    reqs = requisitos(codigo)
    reqs.all? { |r| aprobadas.include?(r) }
  end

  # ---------------------------------------------------------
  # CALCULAR UC ACUMULADAS
  # ---------------------------------------------------------
  def uc_acumuladas(aprobadas)
    aprobadas.map do |codigo|
      materia = buscar(codigo)
      materia ? materia[:uc].to_i : 0
    end.sum
  end

  # ---------------------------------------------------------
  # MATERIAS DISPONIBLES SEGÚN APROBADAS
  # ---------------------------------------------------------
  def disponibles(aprobadas)
    @pensum.select do |m|
      codigo = m[:codigo_oficial].to_s.strip.empty? ? m[:codigo_sistema] : m[:codigo_oficial]
      next if aprobadas.include?(codigo)
      puede_cursar?(codigo, aprobadas)
    end
  end

  # ---------------------------------------------------------
  # MATERIAS POR SEMESTRE
  # ---------------------------------------------------------
  def por_semestre(n)
    @pensum.select { |m| m[:semestre] == n }
  end

  # ---------------------------------------------------------
  # MATERIAS DISPONIBLES POR SEMESTRE
  # ---------------------------------------------------------
  def disponibles_por_semestre(n, aprobadas)
    por_semestre(n).select do |m|
      codigo = m[:codigo_oficial].to_s.strip.empty? ? m[:codigo_sistema] : m[:codigo_oficial]
      puede_cursar?(codigo, aprobadas)
    end
  end

  # ---------------------------------------------------------
  # MÉTODO PRINCIPAL: EVALUAR
  # ---------------------------------------------------------
  def evaluar
    resultado = []

    @pensum.each do |materia|
      codigo = materia[:codigo_oficial].to_s.strip.empty? ?
                 materia[:codigo_sistema] :
                 materia[:codigo_oficial]

      estado = @estados[codigo] || "no_aprobada"

      resultado << {
        codigo: codigo,
        nombre: materia[:nombre],
        estado: estado,
        requisitos: materia[:requisitos],
        uc: materia[:uc],
        semestre: materia[:semestre]
      }
    end

    {
      resumen: {
        total_materias: @pensum.size,
        aprobadas: @estados.select { |_, v| v == "aprobada" }.keys.size,
        uc_acumuladas: uc_acumuladas(@estados.select { |_, v| v == "aprobada" }.keys)
      },
      detalle: resultado
    }
  end
end
