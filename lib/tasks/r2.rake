# Direct uploads go from the browser to R2, which means R2 has to accept a
# cross-origin PUT from this site. Without this the upload fails in the browser
# with a CORS error and nothing reaches the bucket.
#
# Setting it through the API needs a token with bucket admin rights. The app's
# own token deliberately only has object read/write, so this task usually cannot
# apply the rule itself -- it prints the policy to paste into the Cloudflare
# dashboard instead (R2 -> bucket -> Settings -> CORS Policy).
namespace :r2 do
  desc "Allow direct uploads from ORIGINS (comma separated) onto the R2 bucket"
  task configure_cors: :environment do
    require "aws-sdk-s3"
    require "json"

    origins = ENV.fetch("ORIGINS", "https://#{ENV.fetch("APP_HOST", "localhost:3000")}").split(",").map(&:strip)

    client = Aws::S3::Client.new(
      access_key_id: ENV.fetch("R2_ACCESS_KEY_ID"),
      secret_access_key: ENV.fetch("R2_SECRET_ACCESS_KEY"),
      endpoint: ENV.fetch("R2_ENDPOINT"),
      region: "auto",
      force_path_style: true,
      request_checksum_calculation: "when_required",
      response_checksum_validation: "when_required"
    )

    client.put_bucket_cors(
      bucket: ENV.fetch("R2_BUCKET"),
      cors_configuration: {
        cors_rules: [ {
          allowed_origins: origins,
          allowed_methods: %w[ PUT GET HEAD ],
          allowed_headers: %w[ * ],
          expose_headers: %w[ Origin Content-Type Content-MD5 Content-Disposition ETag ],
          max_age_seconds: 3600
        } ]
      }
    )

    puts "  CORS aplicado a #{ENV.fetch("R2_BUCKET")} para: #{origins.join(", ")}"
  rescue Aws::S3::Errors::AccessDenied
    warn "  Este token no puede configurar el bucket (sólo tiene permisos sobre objetos)."
    warn "  Pegá esto en Cloudflare -> R2 -> #{ENV.fetch("R2_BUCKET")} -> Settings -> CORS Policy:\n\n"
    puts JSON.pretty_generate([ {
      "AllowedOrigins" => origins,
      "AllowedMethods" => %w[ PUT GET HEAD ],
      "AllowedHeaders" => %w[ * ],
      "ExposeHeaders" => %w[ Origin Content-Type Content-MD5 Content-Disposition ETag ],
      "MaxAgeSeconds" => 3600
    } ])
  end

  desc "Show the CORS rules currently on the bucket"
  task show_cors: :environment do
    require "aws-sdk-s3"

    client = Aws::S3::Client.new(
      access_key_id: ENV.fetch("R2_ACCESS_KEY_ID"),
      secret_access_key: ENV.fetch("R2_SECRET_ACCESS_KEY"),
      endpoint: ENV.fetch("R2_ENDPOINT"), region: "auto", force_path_style: true,
      request_checksum_calculation: "when_required",
      response_checksum_validation: "when_required"
    )

    client.get_bucket_cors(bucket: ENV.fetch("R2_BUCKET")).cors_rules.each do |rule|
      puts "  origenes: #{rule.allowed_origins.join(', ')}"
      puts "  metodos:  #{rule.allowed_methods.join(', ')}"
    end
  rescue Aws::S3::Errors::NoSuchCORSConfiguration
    puts "  el bucket no tiene reglas CORS"
  end
end
