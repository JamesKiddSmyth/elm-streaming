  function initElmPorts(app)
  {
    var sources = {};

    function sendChunkToElm(event) {
        app.ports.receiveChunk.send({
            completion: event.completion, 
        });
    }
    
    function sendStopToElm(event) {
        app.ports.receiveStop.send({
            stopReason: event.stopReason, 
        });
    }

    function sendDoneToElm(event) {
        app.ports.receiveDone.send({
            done: true, 
        });
    }

    async function query (question) {
  
        const response = await fetch(' http://127.0.0.1:5000/querystream', {
            headers: {
              "accept": "*/*",
              "accept-language": "en-US,en;q=0.9",
              "content-type": "application/json",
              "corpus-id": "Vizio v4.O.3",
              "sec-fetch-dest": "empty",
              "sec-fetch-mode": "cors",
              "sec-fetch-site": "cross-site",
              "user-id": "ca89daff-b647-4b72-a065-d68beb13cfd1",
              "mode": "no-cors",
              "credentials": "omit"
              },
            body: JSON.stringify({
              query: question,
              conversation_uuid: null,
              new_conversation: true
              }),
              //"{\"query\":\"can you help me with my neflix.  List the steps as 'first' rather than 'step 1', 'second' rather than 'step 2', etc\",\"conversation_uuid\":null,\"new_conversation\":true}",
            method: "POST",
            referrer: "http://localhost:3000/",
            referrerPolicy: "strict-origin-when-cross-origin",
          });
    
        if (!response.body) return;
        const reader = response.body
          .pipeThrough(new TextDecoderStream())
          .getReader();
        while (true) {
          var { value, done } = await reader.read();
          if (done) break;
          console.log("Stream chunk received: " + value);
          app.ports.receiveChunk.send(value);
        }
        app.ports.receiveDone.send("DONE");
      }

    app.ports.sendMessage.subscribe(function(message) {
        query(message);
    });

  }
