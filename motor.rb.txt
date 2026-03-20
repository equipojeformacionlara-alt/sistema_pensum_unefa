class MotorAcademico
  def initialize(pensum, estados_estudiante)
    @pensum = pensum
    @estados = estados_estudiante || {}
    @resultado = nil
  end

  # ============================================================
  # MÉTODO PRINCIPAL
  # ============================================================
  def evaluar
    # Clonamos el pensum plano
    @resultado = deep_clone(@pensum)

    # Normalizamos: agregamos campo :codigo = codigo_sistema
    @resultado.each do |mat|
      mat[:codigo] = mat[:codigo_sistema]
    end

    # 1. Evaluación base
    @resultado.each do |mat|
      mat[:estado] = evaluar_materia(mat)
    end

    # 2. Reglas UNEFA
    aplicar_reglas_electivas
    aplicar_reglas_liso
    aplicar_equivalencias
    aplicar_materias_repetidas
    desbloquear_institucionales

    @resultado
  end

  # ============================================================
  # EVALUACIÓN BASE
  # ============================================================
  def evaluar_materia(mat)
    codigo = mat[:codigo]
    estado_est = @estados[codigo]

    return "aprobada" if estado_est == "aprobada"
    return "repetir"  if estado_est == "aplazada"

    requisitos = mat[:requisitos] || []
    return "disponible" if requisitos.empty?

    # Verificar requisitos usando ESTADOS CALCULADOS
    if requisitos.all? { |req| estado_aprobado?(req) }
      "disponible"
    else
      "bloqueada"
    end
  end

  # ============================================================
  # REGLAS ESPECIALES UNEFA
  # ============================================================

  # -------------------------
  # Electivas técnicas / no técnicas
  # -------------------------
  def aplicar_reglas_electivas
    et1 = estado_aprobado?("SIS-ET01")
    en1 = estado_aprobado?("SIS-EN01")

    et2 = buscar("SIS-ET02")
    en2 = buscar("SIS-EN02")

    return unless et2 && en2

    if et1 && en1
      et2[:estado] = "disponible"
      en2[:estado] = "disponible"
    elsif et1 && !en1
      et2[:estado] = "disponible"
      en2[:estado] = "bloqueada"
    elsif !et1 && en1
      et2[:estado] = "bloqueada"
      en2[:estado] = "disponible"
    else
      et2[:estado] = "bloqueada"
      en2[:estado] = "bloqueada"
    end
  end

  # -------------------------
  # Regla institucional: estar liso hasta 7mo para cursar electivas de 8vo
  # -------------------------
  def aplicar_reglas_liso
    return unless liso_hasta_semestre?(7)

    %w[SIS-ET02 SIS-EN02].each do |codigo|
      mat = buscar(codigo)
      next unless mat
      mat[:estado] = "disponible" if mat[:estado] == "bloqueada"
    end
  end

  # -------------------------
  # Equivalencias (si las agregas luego)
  # -------------------------
  def aplicar_equivalencias
    @resultado.each do |mat|
      next unless mat[:equivalencias]

      mat[:equivalencias].each do |eq|
        if estado_aprobado?(eq)
          mat[:estado] = "aprobada"
        end
      end
    end
  end

  # -------------------------
  # Materias repetidas (Proyecto I, etc.)
  # -------------------------
  def aplicar_materias_repetidas
    grupos = @resultado.group_by { |m| m[:codigo] }

    grupos.each do |codigo, instancias|
      next unless instancias.size > 1

      instancias.sort_by! { |m| m[:semestre] }

      instancias.each_cons(2) do |prev, nxt|
        if prev[:estado] == "repetir"
          nxt[:estado] = "repetir"
        end
      end
    end
  end

  # -------------------------
  # Materias institucionales
  # -------------------------
  def desbloquear_institucionales
    institucionales = %w[SIS-0508 SIS-0608 SIS-0609 SIS-0806]

    institucionales.each do |codigo|
      mat = buscar(codigo)
      next unless mat
      mat[:estado] = "disponible" unless estado_aprobado?(codigo)
    end
  end

  # ============================================================
  # MÉTODOS AUXILIARES
  # ============================================================

  def estado_aprobado?(codigo)
    return true if @estados[codigo] == "aprobada"

    mat = buscar(codigo)
    return false unless mat
    mat[:estado] == "aprobada"
  end

  def liso_hasta_semestre?(n)
    @resultado.each do |mat|
      next if mat[:semestre] > n
      return false if mat[:estado] == "repetir" || mat[:estado] == "bloqueada"
    end
    true
  end

  def buscar(codigo)
    @resultado.find { |m| m[:codigo] == codigo }
  end

  def deep_clone(obj)
    Marshal.load(Marshal.dump(obj))
  end
end
