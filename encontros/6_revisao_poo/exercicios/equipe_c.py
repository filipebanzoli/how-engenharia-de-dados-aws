import math

class Circulo():
    def __init__(self, raio):
        self.raio = raio

    def area(self):
        return math.pi * (self.raio ** 2)
          
    def perimentro(self):
        c = 2 * math.pi * self.raio
        return c 
    

circulo = Circulo(raio = 10)

######Vamosss

import datetime

class Pessoa():
    def __init__(self, nome: str, pais: str, data_nasc: datetime.date):
        self.nome = nome
        self.pais = pais
        self.data_nasc = data_nasc

    def calcula_idade(self):
        hoje = datetime.date.today()
        idade = hoje.year - self.data_nasc.year
        if hoje < self.data_nasc:
            idade -=1      
        return idade
        

p = Pessoa(nome="Carol",pais="Brazil",data_nasc = datetime.date(2001,1,1))
print(p.calcula_idade())        