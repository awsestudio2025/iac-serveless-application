import os
import json # Necesario para decodificar el string JSON
import psycopg2
from flask import Flask, jsonify

app = Flask(__name__)

# Variable global para almacenar la configuración PARSEADA
# Inicializamos a None, se llenará con la función load_db_config()
DB_CONFIG = None
# Nombre de la variable de entorno que contiene el string JSON COMPLETO del secreto de RDS
DB_CREDENTIALS_ENV_KEY = "DB_CREDENTIALS" 

def load_db_config():
    """
    Lee la variable de entorno DB_CREDENTIALS, la decodifica de JSON
    y almacena los valores individuales en la variable global DB_CONFIG.
    """
    global DB_CONFIG
    
    # 1. Obtener el string JSON del entorno
    db_credentials_json_string = os.environ.get(DB_CREDENTIALS_ENV_KEY)

    if not db_credentials_json_string:
        print(f"ALERTA: Variable de entorno '{DB_CREDENTIALS_ENV_KEY}' no encontrada.")
        DB_CONFIG = {"status": "error", "reason": "Environment variable not set."}
        return

    try:
        # 2. PASO CRÍTICO: Decodificar el string JSON a un diccionario Python
        credentials = json.loads(db_credentials_json_string)
        
        # 3. Mapear las claves del secreto a una configuración útil
        DB_CONFIG = {
            "host": credentials.get("host"),
            "port": credentials.get("port", 5432),
            "user": credentials.get("username"), # AWS usa 'username'
            "password": credentials.get("password"),
            "database": credentials.get("dbname"),    # AWS usa 'dbname'
        }
        print("INFO: Credenciales de DB cargadas y parseadas exitosamente.")

    except json.JSONDecodeError as e:
        print(f"ERROR: Falló el parsing de JSON para DB_CREDENTIALS: {e}")
        DB_CONFIG = {"status": "error", "reason": f"JSON Decode Error: {e}"}
    except Exception as e:
        print(f"ERROR: Error inesperado al cargar credenciales: {e}")
        DB_CONFIG = {"status": "error", "reason": f"Unexpected error: {e}"}


def get_db_connection():
    """Intenta conectar a la base de datos PostgreSQL usando la configuración global."""
    
    # Aseguramos que la configuración haya sido cargada
    if DB_CONFIG is None or DB_CONFIG.get("status") == "error":
        print("ERROR: La configuración de la base de datos no está disponible.")
        return None

    conn = None
    try:
        # Intenta la conexion, esperando 5 segundos por si la DB se esta iniciando
        conn = psycopg2.connect(
            host=DB_CONFIG["host"],
            database=DB_CONFIG["database"],
            user=DB_CONFIG["user"],
            password=DB_CONFIG["password"],
            port=DB_CONFIG["port"],
            connect_timeout=5
        )
        return conn
    except Exception as e:
        # Aquí capturamos errores de credenciales, red o permisos
        print(f"ERROR: No se pudo conectar a la base de datos: {e}")
        return None

# --- Endpoints de la Aplicación ---

@app.route('/')
def home():
    """Endpoint principal para el Health Check y prueba de conectividad."""
    return jsonify({
        "status": "ok",
        "message": "Bienvenido al Backend de JFC. Intente /db-status o /config-status."
    }), 200

@app.route('/config-status')
def config_status():
    """
    Endpoint de debug: Muestra qué configuración se cargó
    (omitiendo la contraseña).
    """
    if DB_CONFIG is None:
        return jsonify({"status": "error", "message": "DB_CONFIG no inicializado."}), 500
        
    if DB_CONFIG.get("status") == "error":
        return jsonify(DB_CONFIG), 500

    # Retornar la configuración, enmascarando la contraseña por seguridad
    safe_config = DB_CONFIG.copy()
    safe_config['password'] = '***REDACTED***'
    
    return jsonify({
        "status": "ok",
        "message": "Configuración de DB cargada correctamente desde Secrets Manager (JSON parseado).",
        "config": safe_config
    }), 200

@app.route('/db-status')
def db_status():
    """Prueba la conexion a la DB e intenta ejecutar una consulta simple."""
    
    # Asegura que la configuración se haya cargado antes de intentar conectar
    if DB_CONFIG is None or DB_CONFIG.get("status") == "error":
        return jsonify({
             "status": "error",
             "message": "Error de configuración: No se pudo parsear el secreto de DB. Ejecute /config-status para depurar."
        }), 500

    conn = get_db_connection()
    if conn is None:
        # Si la conexión falla AHORA, ya no es un problema de parsing, 
        # sino de red (Security Groups) o estado de RDS.
        return jsonify({
            "status": "error",
            "message": "Fallo la conexion a la Base de Datos. Revise Security Groups, Subnets o estado de RDS."
        }), 500

    try:
        cur = conn.cursor()
        
        # Consulta de prueba: obtener la version de PostgreSQL
        cur.execute("SELECT version();")
        db_version = cur.fetchone()[0]
        
        cur.close()
        
        return jsonify({
            "status": "ok",
            "message": "Conexion a DB exitosa y credenciales validadas.",
            "db_version": db_version,
            "connected_to": f"{DB_CONFIG['user']}@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}"
        }), 200
        
    except Exception as e:
        # Esto podria capturar errores de permisos o de sintaxis SQL
        return jsonify({
            "status": "error",
            "message": f"Error al ejecutar consulta en la DB: {e}"
        }), 500
        
    finally:
        if conn:
            conn.close()

# --- Lógica de Inicialización ---
# Llamamos a la función de carga de configuración al inicio de la aplicación
# para que DB_CONFIG esté disponible antes de la primera solicitud.
load_db_config()

if __name__ == '__main__':
    # Usamos Gunicorn para produccion. Flask en 8080 para que el SG/ALB funcione.
    # En un entorno real usaria un WSGI como Gunicorn o uWSGI.
    app.run(debug=True, host='0.0.0.0', port=8080)
