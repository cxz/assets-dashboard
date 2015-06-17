var onReady = function() {
    var esSupport = (window.EventSource !== undefined);

    if (!esSupport) {
        //no support, probably IE or old browser.
        $('.beacons-status').html('SSE not supported in this browser.');
    }

    var source = new EventSource('/beacons');

    var beaconTemplate = _.template($('#beacon-template').html());

    source.addEventListener('change', function(event) {
        beacons = JSON.parse(event.data);

        var result = "";
        _.each(beacons, function(beacon) {
            result += beaconTemplate(beacon);
        });

        $('.beacons tbody').html(result);

    });

    source.onopen = function(event) {
        $('.beacons-status').html('OK');
        $('.beacons tbody').html(''); //clear list
    };

    source.onmessage = function(event) {
        //update timestamp
    };

    source.onerror = function(event){
        switch( event.target.readyState ){
            case EventSource.CONNECTING:
                $('.beacons-status').html('Reconnecting…');
                break;
            case EventSource.CLOSED:
                $('.beacons-status').html('Connection failed. Will not retry.');
                break;
            case EventSource.OPEN:
                $('.beacons-status').html('OK');
                break;
        }
    };

};

$(document).ready(onReady);
$(document).on('page:load', onReady);

