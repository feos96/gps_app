# Rota com Postos - Aplicativo Flutter

Este aplicativo Flutter permite calcular a rota entre dois pontos (origem e destino) e exibir os postos de combustível mais próximos ao longo da rota. Ele usa APIs de mapeamento como o **OpenRouteService** para calcular a rota e o **Overpass API** para buscar pontos de interesse, como postos de combustível.

## Funcionalidades

- **Pesquisa de Origem e Destino**: O usuário pode buscar e selecionar a origem e o destino digitando o nome de uma cidade, endereço ou estabelecimento.
- **Cálculo de Rota**: A rota entre a origem e o destino é calculada e exibida no mapa.
- **Postos de Combustível**: O app encontra postos de combustível próximos à rota e os exibe no mapa.
- **Exibição no Mapa**: A rota e os postos são visualizados no mapa usando a biblioteca `flutter_map`.

## Tecnologias e Dependências

- **Flutter**: Framework para desenvolvimento de aplicativos móveis.
- **OpenRouteService**: Para cálculo de rotas e obtenção de coordenadas.
- **Overpass API**: Para busca de pontos de interesse próximos à rota, como postos de combustível.
- **Geocoding**: Para converter o endereço em coordenadas.
- **flutter_typeahead**: Para implementar o campo de busca com sugestões automáticas para a origem e destino.

## Dependências no `pubspec.yaml`

```yaml
dependencies:
  cupertino_icons: ^1.0.2
  geolocator: ^11.1.0
  flutter_map: ^5.0.0
  latlong2: ^0.9.0
  http: ^1.1.0
  flutter_polyline_points: ^2.0.0
  permission_handler: ^11.3.1
  google_maps_flutter: ^2.5.3
  flutter_typeahead: ^4.6.2
  geocoding: ^2.1.0

## Como Funciona

### 1. Tela de Mapa

A tela principal do aplicativo (`MapaScreen`) exibe um mapa interativo onde o usuário pode visualizar a rota entre dois pontos (origem e destino) e os postos de combustível próximos. A tela utiliza a biblioteca `flutter_map` para exibir o mapa e as rotas.

- O mapa é inicializado com a coordenada da **origem**.
- O usuário pode inserir a **origem** e o **destino** manualmente através de campos de pesquisa, e a rota será calculada automaticamente.

### 2. Campo de Pesquisa (Autocomplete)

A aplicação utiliza a biblioteca `flutter_typeahead` para implementar campos de pesquisa com sugestões automáticas. Esses campos permitem que o usuário digite o nome de uma cidade, endereço ou até o nome de um estabelecimento, e o app sugere automaticamente possíveis opções.

- O **campo de origem** e o **campo de destino** funcionam da mesma maneira.
- O usuário pode começar a digitar e verá sugestões relacionadas aos lugares que estão sendo buscados.
- A pesquisa pode aceitar tanto **endereços completos** quanto **nomes de cidades ou estabelecimentos**.

### 3. Cálculo da Rota e Exibição no Mapa

Depois que o usuário selecionar os locais de **origem** e **destino**, o app calcula a rota entre esses dois pontos usando o **OpenRouteService (ORS)**. A rota gerada é exibida no mapa, conectando os dois pontos.

- O cálculo da rota é realizado por meio da função `ORSService.calcularRota`, que envia as coordenadas de origem e destino para a API do OpenRouteService e recebe uma lista de coordenadas para a rota.
- Essa rota é exibida no mapa como uma linha azul, usando a camada `PolylineLayer` do `flutter_map`.

### 4. Busca de Postos de Combustível

A aplicação faz uma chamada à **Overpass API** para buscar postos de combustível próximos à rota calculada. O serviço `OverpassService.buscarPostosProximos` é responsável por retornar uma lista de postos dentro de um raio de 5 km da rota.

- Os postos de combustível encontrados são representados no mapa como **marcadores personalizados**.
- Esses marcadores permitem ao usuário ver os postos mais próximos à sua rota, facilitando a escolha de onde parar para abastecer.

### 5. Exibição de Postos de Combustível

Os postos de combustível encontrados são exibidos no mapa como **marcadores**. O app utiliza a classe `CustomMarkers` para definir ícones personalizados para a origem, destino e postos de combustível.

- **Origem**: Marcador com ícone de localização verde.
- **Destino**: Marcador com ícone de bandeira vermelha.
- **Postos de Combustível**: Marcadores com ícones de bomba de combustível.

Cada marcador tem a função de representar um ponto específico no mapa, seja a origem, o destino ou os postos de combustível encontrados ao longo da rota.

### 6. Interação com o Mapa

- O usuário pode **interagir com o mapa**, realizando zoom, movendo o mapa e clicando nos marcadores para visualizar detalhes.
- O mapa exibe a rota entre os pontos selecionados, tornando fácil para o usuário visualizar o percurso completo.
- As coordenadas dos postos de combustível próximos são calculadas automaticamente, e o mapa é atualizado com esses novos marcadores.

### 7. Feedback ao Usuário

- Quando os dados estão sendo carregados (como durante o cálculo da rota ou a busca de postos de combustível), o app exibe um **ícone de carregamento** para indicar que a operação está em andamento.
- Caso haja algum erro durante o processo, uma mensagem de erro é exibida no console para depuração.

---

Essa é a explicação sobre o funcionamento do app. Ele integra mapas interativos, busca de rotas e postos de combustível, tornando a experiência do usuário mais prática e intuitiva ao planejar viagens.

