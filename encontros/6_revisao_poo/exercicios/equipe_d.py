from math import pi


class Circulo:
    def __init__(self, raio) -> None:
        self.raio = raio

    def area_circulo(self) -> float:
        return pi * self.raio**2


objeto = Circulo(2)
objeto.area_circulo()

########

import datetime
import math


class Pessoa:
    def __init__(self, name: str, country: str, date_birth: datetime):
        self.name = name
        self.country = country
        self.date_birth = date_birth

    @property
    def idade(self) -> int:
        # date_birth = pd.to_datetime(self.date_birth)
        # year_date_birth = self.date_birth.dt.year

        return math.floor((datetime.date.today() - self.date_birth).days / 375)


pessoa = Pessoa(name="Jorginho Santos", country="Brazil", date_birth=datetime.date(1988, 1, 5))

print(pessoa.name)
print(pessoa.country)
print(pessoa.idade)

##Funcionando!
