json.extract! pokemon, :id, :name, :image, :created_at, :updated_at
json.url pokemon_url(pokemon, format: :json)
