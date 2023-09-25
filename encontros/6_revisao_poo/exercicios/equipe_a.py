import math
from datetime import date

# class Circulo:
#     def __init__(self, raio):
#         self.raio = raio

#     def perimetro(self, raio):
#         return 2*math.pi*self.raio
    
#     def area(self, raio):
#         return math.pi * (raio * raio)
    
# circulo = Circulo(2)
# print(circulo.area())
# print(circulo.perimeter())

#######
# create a person class. 
# include attributes like name, country and date of birth. 
# implement a method to determine the person's age.

class Person:
    def __init__(self, name:str, country:str, birth_date:date):
        self.name = name
        self.country = country
        self.birth_date = birth_date
    
    def calculate_age(self):
        today = date.today()
        age = today.year - self.birth_date.year
  
        if today < date(today.year, self.birth_date.month, self.birth_date.day):
            age -= 1
        return age

pessoa01 = Person('Flavia', 'Brasil', date(1999, 3, 2))
pessoa02 = Person('Mauricio', 'Brasil', date(1995, 7, 30))

print(pessoa01.calculate_age())
print(pessoa02.calculate_age())
