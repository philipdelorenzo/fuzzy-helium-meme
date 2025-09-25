from sqlalchemy import Column, String
from sqlalchemy.orm import declarative_base
from sqlalchemy.orm import Mapped, mapped_column


Base = declarative_base()

class Contact(Base):
    __tablename__ = 'contacts'
    
    id: Mapped[int] = mapped_column(primary_key=True)
    name = Column(String, index=True)
    email = Column(String, unique=True, index=True)

    def __repr__(self):
        return f"<Contact(id='{self.id}', name='{self.name}', email='{self.email}')>"
