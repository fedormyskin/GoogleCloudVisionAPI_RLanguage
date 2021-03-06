library(RCurl)
library(httr)
library(RJSONIO)
#Note: Please change the broswer key of your own.
browserKey = "YOUR_BROWSER_KEY"

extractJSONContent <- function(x){
    test <- list()
    print(paste("$description: ", x[[1]]$description ))
    return(test)
}

parseFigure <- function(figureName, directorayName){
    # Read the file and turn the binary figure into the base64 string.
    f = paste(getwd(), directorayName, figureName, sep = .Platform$file.sep)
    img = readBin(f, "raw", file.info(f)[1, "size"])
    b64 = base64Encode(img, "character")
    
    # Save the base64 string into a text file.
    fileName = sprintf("base64figure%s.txt", sample(1:100000, 1))
    fileConn<-file(fileName)
    lines = paste("{
      \"requests\":[
        {
          \"image\":{
            \"content\":\"", b64, "\"
                     },
    \"features\":[
      {
        \"type\":\"TEXT_DETECTION\",
        \"maxResults\":3
      }
      ]
    }
    ]
    }")
    writeLines(lines, fileConn)
    close(fileConn)
    
    # Call the Google Vision API. Please input your broswer key here.
    httpheader1 <- c(Accept="application/json; charset=UTF-8",
                "Content-Type"="application/json", "Content-Length"= nchar(lines))
                
    r <- POST(paste("https://vision.googleapis.com/v1/images:annotate?key=", browserKey), httpheader=httpheader1,
        body=upload_file(fileName), encode="json", verbose())
    jsonText <- content(r, type = "application/json")
    results = extractJSONContent(jsonText$responses[[1]]$textAnnotations)
    file.remove(fileName)
    
    return(results)    
}

parseFigure("NonEarthquake7.jpg", directorayName = "images")