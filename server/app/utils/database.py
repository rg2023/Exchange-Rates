from google.cloud.sql.connector import Connector
import sqlalchemy
from app.utils.secret import get_secret

def insert_data(project_id: str, base_currency: str, exchange_rates: list):
    connector = Connector()
    db_user = get_secret("db-user", project_id)
    db_password = get_secret("db-password", project_id)
    db_name = get_secret("db-name", project_id)
    connection_name = get_secret("db-host", project_id)

    def getconn():
        return connector.connect(
            connection_name,
            "pymysql",
            user=db_user,
            password=db_password,
            db=db_name,
        )

    engine = sqlalchemy.create_engine(
        "mysql+pymysql://",
        creator=getconn,
    )

    create_table_sql = """
    CREATE TABLE IF NOT EXISTS my_table (
        id INT AUTO_INCREMENT PRIMARY KEY,
        base_currency VARCHAR(255),
        target_currency VARCHAR(255),
        rate FLOAT
    );
    """

    insert_sql = """
    INSERT INTO my_table (base_currency, target_currency, rate)
    VALUES (:base_currency, :target_currency, :rate);
    """

    with engine.begin() as conn:
        print("🔵 Creating table if not exists...")
        conn.execute(sqlalchemy.text(create_table_sql))
        print("🟢 Inserting rows...")
        for row in exchange_rates:
            print(f" 🔵🟢Inserting {row['currency']} with rate {row['rate']}")
            conn.execute(sqlalchemy.text(insert_sql), {
                "base_currency": base_currency,
                "target_currency": row["currency"],
                "rate": row["rate"]
            })
