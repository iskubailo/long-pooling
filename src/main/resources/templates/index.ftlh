<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>ISLab: Long pool</title>
</head>
<body>

<h3>ISLab: Long pool</h3>

<div>Indetificator:
    <input id="id" value="browser-0">
    <input id="start" type="button" value="Start">
    <input id="stop" type="button" value="Stop">
    <input id="get" type="button" value="Get">
    <input id="increment" type="button" value="Increment">
</div>

<div>Counter: <span id="content">?</span></div>
<div>Status: <span id="status">Idle</span> (<span id="requests">0</span> requests active)</div>

<div>Logs:<div id="log"></div></div>

<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script>
    $( document ).ready(function() {
        let sequence = 1;
        let counter = -1;
        let active = false;
        let requests = 0;

        const log = function(message, id) {
            const prev = $("#log").html();
            if (id) {
                $("#" + id).html(message + " at " + new Date().toISOString());
            } else {
                $("#log").html("<div>" + new Date().toISOString() + ": " + message + "</div>" + prev);
            }
        }

        const updateStatus = function(status) {
            if (active) {
                if (status) {
                    $("#status").html(status);
                }
            } else {
                if (requests > 0) {
                    $("#status").html("Stopping");
                } else {
                    $("#status").html("Stopped");
                }
            }
        }

        const fetch = function() {
            const requestId = sequence++;
            const url = "/api/fetch/" + $("#id").val() + "/" + counter;
            log("Fetch: " + url + " => <span id='" + requestId + "'>...</span>")
            updateStatus("Fetching");
            requests++;
            $("#requests").html(requests);
            const start = new Date();
            $.ajax({
                url: url,
                success: function(result) {
                    counter = result;
                    $("#content").html(result);
                    const time = (new Date() - start) / 1000;
                    log(result + " (in " + time + " seconds)", requestId);
                    updateStatus("Success");
                },
                complete: function() {
                    requests--;
                    $("#requests").html(requests);
                    if (active) {
                        fetch();
                    }
                    updateStatus();
                }
            });
        }

        $("#start").click(function() {
            active = true;
            fetch();
        });

        $("#stop").click(function() {
            active = false;
            updateStatus();
        });

        $("#get").click(function() {
            const requestId = sequence++;
            const url = "/api/get/";
            log("Get: " + url + " => <span id='" + requestId + "'>...</span>")
            const start = new Date();
            $.ajax({
                url: url,
                success: function(result) {
                    $("#content").html(result);
                    const time = (new Date() - start) / 1000;
                    log(result + " (in " + time + " seconds)", requestId);
                    counter = result;
                }
            });
        });

        $("#increment").click(function() {
            const requestId = sequence++;
            const url = "/api/increment/";
            log("Increment: " + url + " => <span id='" + requestId + "'>...</span>")
            const start = new Date();
            $.ajax({
                url: url,
                success: function(result) {
                    $("#content").html(result);
                    const time = (new Date() - start) / 1000;
                    log(result + " (in " + time + " seconds)", requestId);
                    counter = result;
                }
            });
        });
    });
</script>

</body>
</html>
