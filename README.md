### Parking

API para controle de estacionamento

* Ruby version 2.4

* Rails version 5.0.7

* Docker version 19.03.4

#### Criar aplicação

`$ docker-compose build`

#### Migrar banco

`$ docker-compose run web rails db:migrate`

#### Testes

`$ docker-compose run web rspec`

#### Iniciar Aplicação

`$ docker-compose run web up`