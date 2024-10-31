from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime

class Dish(BaseModel):
    id: int
    name: str
    price: float
    rating: float
    description: str

class Item(BaseModel):
    name: str
    quantity: int

class Order(BaseModel):
    userId:str
    id: str
    status: str
    customer_name: str
    total: float = 0.0
    timestamp: datetime
    items: List[Item] = []

class Rating(BaseModel):
    rating: int = Field(..., ge=1, le=5)
    user_id: str

class DishWithRating(BaseModel):
    id: int
    name: str
    price: float
    description: str
    average_rating: float = 0.0
    total_ratings: int = 0