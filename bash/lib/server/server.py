from urllib import request
from venv import logger
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
import uuid
from typing import Dict, List
from datetime import datetime

from database import SessionLocal, engine
import db_models
from model import Dish, Order, Item,Rating,DishWithRating
from fastapi.middleware.cors import CORSMiddleware
from fastapi import Body
import logging



# Create tables
db_models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Restaurant API")
origins = [
    "http://localhost:3000",  # Flutter web (if applicable)
    "http://127.0.0.1:3000",  # Flutter web (if applicable)
    "http://localhost:8000",   # Your FastAPI server
    "http://127.0.0.1:8000",   # Your FastAPI server
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"]
)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/")
async def read_root():
    return {"message": "Welcome to Restaurant API"}

# Dish endpoints
@app.get("/dishes/", response_model=List[Dish])
async def get_dishes(db: Session = Depends(get_db)):
    dishes = db.query(db_models.DBDish).all()
    return [
        Dish(
            id=dish.id,
            name=dish.name,
            rating=dish.average_rating,  # Use the average_rating from the database
            price=dish.price,
            description=dish.description
        )
        for dish in dishes
    ]
@app.get("/dishes/{dish_id}", response_model=Dish)
async def get_dish(dish_id: int, db: Session = Depends(get_db)):
    dish = db.query(db_models.DBDish).filter(db_models.DBDish.id == dish_id).first()
    if not dish:
        raise HTTPException(status_code=404, detail="Dish not found")
    return Dish(
        id=dish.id,
        name=dish.name,
        price=dish.price,
        description=dish.description
    )

@app.post("/create/", response_model=Dish)
async def create_dish(dish: Dish, db: Session = Depends(get_db)):
    db_dish = db_models.DBDish(
        id=dish.id,
        name=dish.name,
        price=dish.price,
        description=dish.description,
      average_rating=0.0,  # Set default average rating
        total_ratings=0 
    )
    db.add(db_dish)
    try:
        db.commit()
        db.refresh(db_dish)
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    
    return {
        "id": db_dish.id,
        "name": db_dish.name,
        "price": db_dish.price,
        "rating": db_dish.average_rating,  # Return the average_rating instead of the non-existing rating
        "description": db_dish.description
    }

@app.put("/dishes/{dish_id}", response_model=Dish)
async def update_dish(dish_id: int, dish: Dish, db: Session = Depends(get_db)):
    db_dish = db.query(db_models.DBDish).filter(db_models.DBDish.id == dish_id).first()
    if not db_dish:
        raise HTTPException(status_code=404, detail="Dish not found")
    
    for field, value in dish.dict().items():
        setattr(db_dish, field, value)
    
    try:
        db.commit()
        db.refresh(db_dish)
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    return {
        "id": db_dish.id,
        "name": db_dish.name,
        "price": db_dish.price,
        "rating": db_dish.average_rating,  # Return the average_rating instead of the non-existing rating
        "description": db_dish.description
    }
@app.delete("/dishes/{dish_id}")
async def delete_dish(dish_id: int, db: Session = Depends(get_db)):
    db_dish = db.query(db_models.DBDish).filter(db_models.DBDish.id == dish_id).first()
    if not db_dish:
        raise HTTPException(status_code=404, detail="Dish not found")
    
    try:
        db.delete(db_dish)
        db.commit()
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    return {"message": "Dish deleted successfully"}


@app.post("/dishes/{dish_id}/rate", response_model=Dict[str, float])
async def rate_dish(dish_id: int, rating_data: Rating, db: Session = Depends(get_db)):
    # Check if dish exists
    dish = db.query(db_models.DBDish).filter(db_models.DBDish.id == dish_id).first()
    if not dish:
        raise HTTPException(status_code=404, detail=f"Dish with id {dish_id} not found")
    
    # Check if user has already rated this dish
    existing_rating = db.query(db_models.DBRating).filter(
        db_models.DBRating.dish_id == dish_id,
        db_models.DBRating.user_id == rating_data.user_id
    ).first()
    
    try:
        current_time = datetime.utcnow()
        
        if existing_rating:
            # Update existing rating
            old_rating = existing_rating.rating
            existing_rating.rating = rating_data.rating
            existing_rating.timestamp = current_time
            
            # Update dish's average rating
            if dish.total_ratings > 0:
                dish.average_rating = (
                    (dish.average_rating * dish.total_ratings - old_rating + rating_data.rating)
                    / dish.total_ratings
                )
        else:
            # Create new rating
            new_rating = db_models.DBRating(
                dish_id=dish_id,
                user_id=rating_data.user_id,
                rating=rating_data.rating,
                timestamp=current_time
            )
            db.add(new_rating)
            
            # Update dish's average rating
            if dish.total_ratings == 0:
                dish.average_rating = float(rating_data.rating)
            else:
                dish.average_rating = (
                    (dish.average_rating * dish.total_ratings + rating_data.rating)
                    / (dish.total_ratings + 1)
                )
            dish.total_ratings += 1
        
        db.commit()
        
        return {
            "average_rating": round(dish.average_rating, 2),
            "total_ratings": dish.total_ratings
        }
    
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
# Order endpoints
@app.get("/orders", response_model=List[Order])
async def get_orders(db: Session = Depends(get_db)):
    orders = db.query(db_models.DBOrder).all()
    return [Order(
        id=order.id,
        userId=order.userId,
        status=order.status,
        customer_name=order.customer_name,  
        total=order.total,
        timestamp=order.timestamp,
        items=[Item(name=item.name, quantity=item.quantity) for item in order.items]
    ) for order in orders]


@app.get("/View_orders/{user_id}", response_model=List[Order])  # Note the List[Order]
async def get_orders(user_id: str, db: Session = Depends(get_db)):
    orders = db.query(db_models.DBOrder).filter(db_models.DBOrder.userId == user_id).all()
    if not orders:
        return []
    return orders

@app.post("/Createorders/", status_code=201)
async def create_order(order: Order, db: Session = Depends(get_db)):
    logger.info("Received request to create order with data: %s", order.dict())

    # Create a new order instance
    db_order = db_models.DBOrder(
        id=order.id,
        userId=order.userId,
        status=order.status,
        customer_name=order.customer_name,  
        total=order.total,
        timestamp=order.timestamp
    )

    # Log order creation details
    logger.info("Creating DB order: %s", db_order)

    # Create items
    db_items = []
    for item in order.items:
        logger.info("Adding item to order: %s", item)
        db_items.append(db_models.DBItem(
            name=item.name,
            quantity=item.quantity,
            order_id=order.id  # Make sure to set the order_id
        ))

    # Log the items to be added
    logger.info("Items to be added to the order: %s", db_items)

    db.add(db_order)
    db.add_all(db_items)  # Add all items at once
    
    try:
        db.commit()
        db.refresh(db_order)
        logger.info("Order created successfully: %s", db_order)
    except Exception as e:
        logger.error("Error while creating order: %s", str(e))
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    return {"message": "Order created successfully", "order_id": db_order.id}
    
    

@app.get("/orders/{order_id}", response_model=Order)
async def get_order(order_id: str, db: Session = Depends(get_db)):
    db_order = db.query(db_models.DBOrder).filter(db_models.DBOrder.id == order_id).first()
    if not db_order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    return Order(
        id=db_order.id,
        userId=db_order.userId,
        status=db_order.status,
        customerName=db_order.customer_name,
        total=db_order.total,
        timestamp=db_order.timestamp,
        items=[Item(name=item.name, quantity=item.quantity) for item in db_order.items]
    )

# Add this new endpoint for status updates only
@app.put("/orders/{order_id}/status")
async def update_order_status(
    order_id: str, 
    status: str = Body(..., embed=True),
    db: Session = Depends(get_db)
):
    db_order = db.query(db_models.DBOrder).filter(db_models.DBOrder.id == order_id).first()
    if not db_order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    db_order.status = status
    
    try:
        db.commit()
        db.refresh(db_order)
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    
    return {"message": "Order status updated successfully"}

@app.delete("/orders/{order_id}")
async def delete_order(order_id: str, db: Session = Depends(get_db)):
    db_order = db.query(db_models.DBOrder).filter(db_models.DBOrder.id == order_id).first()
    if not db_order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    try:
        db.delete(db_order)
        db.commit()
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    return {"message": "Order deleted successfully"}

@app.get("/users/{user_id}/orders/", response_model=List[Order])
async def get_user_orders(user_id: str, db: Session = Depends(get_db)):
    orders = db.query(db_models.DBOrder).filter(db_models.DBOrder.userId == user_id).all()
    return [Order(
        id=order.id,
        userId=order.userId,
        status=order.status,
        customer_name=order.customer_name,
        total=order.total,
        timestamp=order.timestamp,
        items=[Item(name=item.name, quantity=item.quantity) for item in order.items]
    ) for order in orders]