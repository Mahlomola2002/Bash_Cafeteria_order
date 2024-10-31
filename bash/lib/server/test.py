from sqlalchemy import create_engine
from sqlalchemy.orm import Session
from datetime import datetime
from database import metadata, dishes, orders, order_items

def test_database_operations():
    # Create an in-memory SQLite database
    engine = create_engine("sqlite:///:memory:")
    
    # Create all tables in the in-memory database
    metadata.create_all(engine)
    
    # Start a new session
    with Session(engine) as session:
        # Insert a dish
        dish_data = {
            "id": 1,
            "name": "Pizza",
            "price": 12.5,
            "description": "Delicious cheese pizza"
        }
        session.execute(dishes.insert().values(dish_data))

        # Insert an order
        order_data = {
            "id": 1,
            "status": "pending",
            "customer_name": "John Doe",
            "total": 12.5,
            "timestamp": datetime.utcnow()
        }
        session.execute(orders.insert().values(order_data))

        # Insert into order_items
        order_item_data = {
            "order_id": 1,
            "dish_id": 1,
            "quantity": 2
        }
        session.execute(order_items.insert().values(order_item_data))

        # Commit the session to save the changes
        session.commit()

        # Query to verify insertion
        order_query = session.execute(orders.select()).fetchall()
        dish_query = session.execute(dishes.select()).fetchall()
        order_item_query = session.execute(order_items.select()).fetchall()

        print("Orders:", order_query)
        print("Dishes:", dish_query)
        print("Order Items:", order_item_query)

if __name__ == "__main__":
    test_database_operations()