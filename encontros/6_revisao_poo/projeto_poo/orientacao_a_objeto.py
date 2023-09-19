import datetime
import math


class Pessoa:
    def __init__(self, nome: str, sobrenome: str, data_de_nascimento: datetime.date):
        self.data_de_nascimento = data_de_nascimento
        self.sobrenome = sobrenome
        self.nome = nome

    @property
    def idade(self) -> int:
         return math.floor((datetime.date.today() - self.data_de_nascimento).days / 365.2425)

    def __str__(self) -> str:
        return f"{self.nome} {self.sobrenome} tem {self.idade} anos"


andre = Pessoa(nome='Andre', sobrenome='Sionek', data_de_nascimento=datetime.date(1991, 1, 9))


print(andre)
print(andre.nome)
print(andre.sobrenome)
print(andre.idade)