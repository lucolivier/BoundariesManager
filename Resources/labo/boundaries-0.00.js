

function log (param) { console.log(param); }

function toRad(val) {
	return val*Math.PI/180;
}

function trueSphericalDistance (dot1,dot2) {
	var dLatRad=toRad(dot2.lat-dot1.lat);
	var dLngRad=toRad(dot2.lng-dot1.lng);
	var lat1Rad=toRad(dot1.lat);
	var lat2Rad=toRad(dot2.lat);
	
	var a=Math.pow(Math.sin(dLatRad/2),2)+Math.cos(lat1Rad)*Math.cos(lat2Rad)*Math.pow(Math.sin(dLngRad/2),2);
	var c=2*Math.atan2(Math.sqrt(a),Math.sqrt(1-a));
	return 6371*c;
}

function sphericalDistance (dot1, dot2) {
	var d1lat=toRad(dot1.lat);
	var d1lng=toRad(dot1.lng);
	var d2lat=toRad(dot2.lat);
	var d2lng=toRad(dot2.lng);
	var x = (d2lng-d1lng)*Math.cos(d1lng);
	var y = (d2lat-d1lat);
	return 6371*Math.sqrt(Math.pow(x,2)+Math.pow(y,2));
}

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



											 											 
function drawBound() {
	var markerImage = new google.maps.MarkerImage(      "img_handle.png",
														 new google.maps.Size(11,11), //11,11
														 null,
														 new google.maps.Point(5,5)
												 );
	var markerImageStart = new google.maps.MarkerImage(  "img_handle_ends.png",
														 new google.maps.Size(11,11),
														 null,
														 new google.maps.Point(5,5)
												 );
	var markers=[]; var dot;
//	var sum=0;
//log(bound.length);
	for (var i=0; i<bound.length; i++) {
// 		if (i<bound.length-1) {
// 			dist=sphericalDistance(makeDot(bound[i]),makeDot(bound[i+1]));
// 		} else {
// 			dist=sphericalDistance(makeDot(bound[i]),makeDot(bound[0]));
// 		}
// 		sum+=dist;
// log(i+":"+bound[i].lat+","+bound[i].lon+" >"+dist);
		if (i==0 || i==5) { markerImg=markerImageStart; } else { markerImg=markerImage; }

		dot=new google.maps.LatLng(bound[i].lat,bound[i].lon);
		markers[i] = new google.maps.Marker({
											position:           dot,
											map:                map,
											icon:               markerImg,
											raiseOnDrag:        false,
											draggable:          false
											});

		//if (i==5) break;
	}
// 	log(">>>>>>"+sum);
	map.setCenter(new google.maps.LatLng(bound[0].lat,bound[0].lon));

	//drawBoundReduced();
}

function drawBoundReduced() {
	var markerImage2 = new google.maps.MarkerImage(      "img_handle_ends.png",
														 new google.maps.Size(11,11),
														 null,
														 new google.maps.Point(5,5)
												 );
	var markerImageStart = new google.maps.MarkerImage(  "img_handle.png",
                                                       new google.maps.Size(11,11),
                                                       null,
                                                       new google.maps.Point(5,5)
                                                       );

	
    var markers=[];
	for (var i=0; i<polygonReduced.length; i++) {
        if (i%10==0) { markerImg=markerImageStart; } else { markerImg=markerImage2; }
		
        dot=new google.maps.LatLng(polygonReduced[i].lat,polygonReduced[i].lon);
		markers[i] = new google.maps.Marker({
									position:           dot,
									map:                map,
									icon:               markerImg,
									raiseOnDrag:        false,
									draggable:          false
									});
	}
    
    map.setCenter(new google.maps.LatLng(polygonReduced[0].lat,polygonReduced[0].lon));
}
