# 📘 Sistema de Pensum UNEFA  
Sistema académico para visualizar, consultar y analizar el avance del estudiante de Ingeniería de Sistemas (UNEFA).

Este proyecto permite cargar el pensum oficial, mostrar materias aprobadas, disponibles y bloqueadas, y calcular el progreso académico de forma visual e interactiva.

---

## 🚀 Características principales

- Visualización completa del pensum por semestres  
- Cálculo automático de:
  - Materias aprobadas  
  - Materias disponibles  
  - Materias bloqueadas por requisitos  
  - Materias sin requisitos  
- Lectura dinámica del archivo `pensum.json`  
- Interfaz clara y fácil de usar  
- Compatible con GitHub Pages (publicación web)

---

## 📂 Estructura del proyecto


---

## 📄 Archivo pensum.json

El archivo `pensum.json` contiene **todo el pensum oficial**, organizado por semestres, con:

- Código oficial UNEFA  
- Código interno del sistema  
- Nombre de la materia  
- Unidades de crédito  
- Requisitos académicos  

Ejemplo:

```json
{
  "semestre": 3,
  "codigo_oficial": "MAT-21235",
  "codigo_sistema": "SIS-0302",
  "nombre": "MATEMÁTICA III",
  "uc": 5,
  "requisitos": ["MAT-21225"]
}

---

## 👨‍💻 Autor
Dr. Leonardo Caraballo  
Sistema académico para la UNEFA
Desarrollo, documentación y estructura del pensum

---
##📜 Licencia
Este proyecto es de uso académico y puede ser adaptado para fines educativos.
