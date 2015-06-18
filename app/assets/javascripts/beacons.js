var onReady = function() {
    var esSupport = (window.EventSource !== undefined);

    if (!esSupport) {
        //no support, probably IE or old browser.
        $('.beacons-status').html('SSE not supported in this browser.');
    }

    var source = new EventSource('/beacons');

    var beaconTemplate = _.template($('#beacon-template').html());

    source.addEventListener('added', function(event) {
        beacon = JSON.parse(event.data);
        $('.beacons tbody').append(beaconTemplate(beacon));
        highlight(beacon);
    });

    source.addEventListener('updated', function(event) {
        beacon = JSON.parse(event.data);
        $('.beacon-' + beacon.id).replaceWith(beaconTemplate(beacon));
        highlight(beacon);
    });

    source.addEventListener('removed', function(event) {
        beacon = JSON.parse(event.data);
        highlight(beacon);
        $('.beacon-' + beacon.id).remove();
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

    function highlight(beacon) {
        $('.beacon-' + beacon.id).animate({ backgroundColor: "yellow" }, "fast").animate({backgroundColor: 'white'}, 'fast');
    }

};

$(document).ready(onReady);
$(document).on('page:load', onReady);

