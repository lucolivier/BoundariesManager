

function log (param) { console.log(param); }



function makeDot(dot) {
	return {lat:dot.lat,lng:dot.lon}
}

var map=null;

var x=-0.5791799999999512;
var y=44.837789;
var addressPoint={x:x,y:y};
mapOptions= {
	zoom:                           14,
	center:                         null,
	/*To get direction arrows rather hand */
	draggableCursor:                'auto',
	draggingCursor:                 'move',
	/**/
    
	panControl:                     false,
	zoomControl:                    false,
	zoomControlOptions: {
		style:                      google.maps.ZoomControlStyle.DEFAULT,
		position:                   google.maps.ControlPosition.LEFT_CENTER
	},
	mapTypeControl:                 false,
	scaleControl:                   false,
	streetViewControl:              false,

	mapTypeId:                      google.maps.MapTypeId.ROADMAP
};


function startMap() {
	log(">");
	mapOptions.center = new google.maps.LatLng(addressPoint.y, addressPoint.x);

	map = new google.maps.Map(document.getElementById('mapdiv'), mapOptions);
	log("<");
}

function drawPolygon() {
	drawPolygonName(bound,"black");
	//drawPolygonName(polygonReduced,"red");
}
function drawPolygonName(array,color) {
	var markerImage = new google.maps.MarkerImage(      "img_handle.png",
														 new google.maps.Size(11,11), //11,11
														 null,
														 new google.maps.Point(5,5)
												 );



	var dots=[]; var dot;

	for (var i=0; i<array.length; i++) {
		dots.push(new google.maps.LatLng(array[i].lat,array[i].lon));
	}

        shapeOptions= {
            strokeColor:                 color,
            strokeOpacity:               0.8,
            strokeWeight:                1,
            fillColor:                   color,
            fillOpacity:                 0.0,
            paths:						dots,
            map:                         map
        };

	shape = new google.maps.Polygon( shapeOptions );

	map.setCenter(new google.maps.LatLng(array[0].lat,array[0].lon));

	//drawBoundReduced();
}

