import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"
import * as intlTelInput from 'intl-tel-input';

let csrfTokenTag = document.querySelector("meta[name='csrf-token']")

if (csrfTokenTag) {
  const csrfToken = csrfTokenTag.getAttribute("content");

  let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}});
  window.liveSocket = liveSocket
  let actualSocket = liveSocket.getSocket()


  actualSocket.onMessage(function(message) {
    var input = document.querySelector("#input-phone");

    if (input !== null) {
      var instance = intlTelInput(input, {
        initialCountry: "IE",
        nationalMode: false,
        geoIpLookup: function(success, failure) {
          $.get("https://ipinfo.io", function() {}, "jsonp").always(function(resp) {
            var countryCode = (resp && resp.country) ? resp.country : "";
            success(countryCode);
          });
        }
      });
    }
  })

  liveSocket.connect()
}
