require "sinatra"
require "json"
require_relative "motor"

require "webrick"
set :server, "webrick"

set :bind, "0.0.0.0"
set :port, 4567

PENSUM = JSON.parse(File.read("pensum.json"), symbolize_names: true)

post "/api/v1/evaluar" do
  content_type :json

  payload = JSON.parse(request.body.read)
  estados = payload["estados"]

  motor = MotorAcademico.new(PENSUM, estados)
  resultado = motor.evaluar

  { estudiante_id: payload["estudiante_id"], resultado: resultado }.to_json
end

get "/api/v1/pensum" do
  content_type :json
  { pensum: PENSUM }.to_json
end

get "/" do
  send_file "index.html"
end



