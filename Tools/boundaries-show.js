

function log (param) { console.log(param); }


var map=null;
var shapes=[];
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

function center(polygon) {
    var sumLng=0; var sumLat=0;
    for (var i=0; i<polygon.length; i++) {
        sumLng+=polygon[i].x;
        sumLat+=polygon[i].y;
    }
    return {lat:sumLat/polygon.length,lng:sumLng/polygon.length};
}

function startMap() {
	log(">");
	mapOptions.center = new google.maps.LatLng(addressPoint.y, addressPoint.x);

	map = new google.maps.Map(document.getElementById('mapdiv'), mapOptions);
	log("<");
}

function loadPolygon() {
    for (var i=0; i<shapes.length; i++) {
        shapes[i].setMap(null);
    }
    
    code=document.getElementById('tfCode').value;
    //alert(code);
    
    if (urlExists("repos/fpjson/"+code)) {
    
    loadScript("repos/fpjson/"+code,function(){
               log(fullpolygon.length);
               shapes.push(drawPolygon(fullpolygon,"black"));
               });
    loadScript("repos/rpjson/"+code,function(){
               log(reducedpolygon.length);
               shapes.push(drawPolygon(reducedpolygon,"red"));
               centreMap();
               });

    } else {
        alert("Code not exists!");
    }
}

function urlExists(url) {
    var http = new XMLHttpRequest();
    http.open('HEAD', url, false);
    http.send();
    //alert(http.status);
    return http.status==0;
}
    
function loadScript(url, callback) {
    var head=document.getElementsByTagName('head')[0];
    var script=document.createElement('script');
    script.type='text/javascript';
    script.src=url;
    script.onreadystatechange=callback;
    script.onload=callback;
    head.appendChild(script);
}

function drawPolygons() {
    shapes.push(drawPolygon(fullpolygon,"black"));
    shapes.push(drawPolygon(reducedpolygon,"red"));
    centreMap();
    
//    var point={id:"",lat:46.157794184,lng:4.92492482307693};
//    drawPoint(point);
//    map.setCenter(new google.maps.LatLng(point.y,point.x));
}

function centreMap() {
    centre=center(reducedpolygon);
log(centre);
    map.setCenter(new google.maps.LatLng(centre.lat,centre.lng));    
}

function drawPolygon(array,color) {
    log("drawPolygon:"+array.length);

	var dots=[];

	for (var i=0; i<array.length; i++) {
		dots.push(new google.maps.LatLng(array[i].y,array[i].x));
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

	return (new google.maps.Polygon( shapeOptions ));

}

function drawPoint(point) {
	var marker = new google.maps.MarkerImage(      "img_handle.png",
														 new google.maps.Size(11,11), //11,11
														 null,
														 new google.maps.Point(5,5)
												 );
    var dot=new google.maps.LatLng(point.y,point.x);
    new google.maps.Marker({
                                        position:           dot,
                                        map:                map,
                                        icon:               marker,
                                        raiseOnDrag:        false,
                                        draggable:          false
                                        });
}

