from sqlalchemy import Column, ForeignKey, Integer, String, Float, DateTime, Table
from sqlalchemy.orm import relationship
from datetime import datetime
from database import Base



class DBOrder(Base):
    __tablename__ = "orders"

    id = Column(String, primary_key=True, index=True)
    userId = Column(String, index=True)
    status = Column(String)
    customer_name = Column(String)
    
    total = Column(Float)
    timestamp = Column(DateTime, default=datetime.utcnow)

class DBItem(Base):
    __tablename__ = "items"

    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(String, ForeignKey("orders.id"))
    name = Column(String)
    quantity = Column(Integer)
    
    order = relationship("DBOrder", backref="items")
class DBDish(Base):
    __tablename__ = "dishes"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    price = Column(Float)
    description = Column(String)
    average_rating = Column(Float, default=0.0)
    total_ratings = Column(Integer, default=0)
    
    ratings = relationship("DBRating", back_populates="dish")

class DBRating(Base):
    __tablename__ = "ratings"

    id = Column(Integer, primary_key=True, index=True)
    dish_id = Column(Integer, ForeignKey("dishes.id"))
    user_id = Column(String, index=True)
    rating = Column(Integer)
    timestamp = Column(DateTime)
    
    dish = relationship("DBDish", back_populates="ratings")
    
    