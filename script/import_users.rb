require 'csv'
require 'net/http'
require 'uri'
require 'json'

class ImportUsers
    def self.importFromCSV(csv_path, url)
        users = CSV.read(csv_path, {headers: true})
        uri = URI.parse(url)
        header = {'Content-Type': 'application/json'}
        users.each_with_index do |row, i|
            user = {user: row.to_hash}
            http = Net::HTTP.new(uri.host, uri.port)
            request = Net::HTTP::Post.new(uri.request_uri, header)
            request.body = user.to_json
            response = http.request(request)
            if(response.code != "201")
                p "Erro no cadastro do usuario na linha #{i}"
                p response.body
            end
        end
    end
end

ImportUsers.importFromCSV(ARGV[0], ARGV[1])