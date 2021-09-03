require 'json'

JSON.
  load_file('pokemons.json').
  each { |j| Pokemon.create! name: j['name'], image: j['image'] }
