get = (url) ->
    new Promise((resolve, reject) ->
        req = new XMLHttpRequest()
        req.open('GET', url)

        req.onload = ->
            if req.status == 200
                resolve(req.response)
            else
                reject(Error(req.statusText))

        req.onerror = ->
            reject(Error("Network error getting: #{url}"))

        req.send()
    )

upload = (file) ->
    new Promise((resolve, reject) ->
        fileReader = new FileReader()

        fileReader.onload = ->
            resolve(fileReader.result)

        fileReader.onerror = ->
            reject(Error("Error reading file"))

        fileReader.readAsText(file)
    )

@get = get
@upload = upload
