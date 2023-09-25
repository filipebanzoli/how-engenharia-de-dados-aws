# Versão que tava no outro arquivo
import math

class Circle:
    def __init__(self, radius):
        self.radius = radius

    def area(self):
        return math.pi * (self.radius ** 2)

    def perimeter(self):
        return 2 * math.pi * self.radius

circle = Circle(2.5)
print(circle.area())
print(circle.perimeter())



#######

from datetime import datetime, date


# Tentativa I
class Person:
    def __init__(self, nome:str, pais:str, datanasc: date):
        
        self.nome = nome

        # Deveria considerar timezone?
        self.pais = pais
        self.datanasc = datanasc

        # jeito I
        self.age = 2023 - int(datanasc.split('/')[-1])

        # jeito II
        today = datetime.strptime(datanasc, "%d/%m/%Y")
        diff = today - datetime.strptime(datanasc, "%d/%m/%Y")
        idade = int(diff.days / 365)
        self.age = idade
        
    def show(self):
        print(self.nome)
        print(self.age)
        
person = Person(
    name = 'alberto',
    country = '',
    born = date(1999, 8, 27)
)
   

person.show()
