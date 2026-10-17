import mysql.connector

# Database connection configuration
# Please replace with your actual database credentials
db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': 'baoqy',
    'database': 'information_schema'  # We need to query information_schema
} 
try:
    # Establish connection
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()
    
    # SQL query
    query = """
    SELECT table_name, CONCAT('``', TABLE_SCHEMA, '``.', table_name, '') as value 
    FROM information_schema.TABLES 
    WHERE TABLE_SCHEMA LIKE 'mftcc-%' 
    ORDER BY TABLE_SCHEMA DESC
    """
    
    # Execute query
    cursor.execute(query)
    
    # Fetch all results
    results = cursor.fetchall()
    
    # Write to data.txt
    with open('mftcc_data.ahk', 'w', encoding='utf-8') as f:
        f.write("GetDataArray() {\n")
        f.write("    data := {}\n")
        
        # Write each row
        for row in results:
            table_name = row[0]
            value = row[1]
            f.write(f"    data[\"{table_name}\"] := \"{value}\"\n")
            
        f.write("    return data\n")
        f.write("}")
    
    print("Data has been successfully written to data.txt")

except mysql.connector.Error as err:
    print(f"Error: {err}")
    
finally:
    # Clean up
    if 'cursor' in locals():
        cursor.close()
    if 'conn' in locals():
        conn.close()