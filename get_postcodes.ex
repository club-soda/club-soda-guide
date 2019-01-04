zip_file_url = "https://raw.githubusercontent.com/dwyl/uk-postcodes-latitude-longitude-complete-csv/master/ukpostcodes.csv.zip"
zip_file_name = "postcodes.zip"
zip_file_name_charlist = String.to_charlist(zip_file_name)
postcode_file_charlist = 'ukpostcodes.csv'


# Helper to unzip file and only take ukpostcodes.csv
# If file is succesfully unziped then it deletes the zip file
unzip_file_name =
  fn() ->
    case :zip.extract(zip_file_name_charlist, [{:file_list, [postcode_file_charlist]}]) do
      {:ok, _fileList} ->
        IO.inspect("Postcodes successfully unzipped")
        File.rm!(zip_file_name)

      {:error, error} ->
        IO.inspect(error)
    end
  end

# Gets zip file from github and saves the response to body
%HTTPoison.Response{body: body} = HTTPoison.get!(zip_file_url)

# Writes the zip file to allow it to be unzipped so the csv can be extracted
case File.write(zip_file_name, body) do
  :ok ->
    unzip_file_name.()

  _ ->
    IO.inspect("failed to write file")
end
