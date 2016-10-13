
function log (param) { console.log(param); }

function toRad(val) {
	return val*Math.PI/180;
}

function distance (dot1,dot2) {
	var dLatRad=toRad(dot2.lat-dot1.lat);
	var dLngRad=toRad(dot2.lng-dot1.lng);
	var lat1Rad=toRad(dot1.lat);
	var lat2Rad=toRad(dot2.lat);
	
	var a=Math.pow(Math.sin(dLatRad/2),2)+Math.cos(lat1Rad)*Math.cos(lat2Rad)*Math.pow(Math.sin(dLngRad/2),2);
	var c=2*Math.atan2(Math.sqrt(a),Math.sqrt(1-a));
	return 6371*c;
}

function searchArray(array,key,value) {
	for (var i=0; i<array.length; i++) {
		if (array[i][key]==value) return i;
	}
	return -1;
}

var map=null;

var x=-0.5791799999999512;
var y=44.837789;
var addressPoint={x:x,y:y};
mapOptions= {
	zoom:                           11,
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

function bound() {

	var polygon=[]; var cpt=0;
	var relmbrs=relations.members;
	for (var r=0; r<relmbrs.length; r++) {
		if (relmbrs[r].type!="way") continue;
	
		wayIdx=searchArray(ways,'id',relmbrs[r].ref);
	//log (relmbrs[r].ref+": "+wayIdx);
	
		curWay=ways[wayIdx].nodes;
		
		for (w=0; w<curWay.length-1; w++) {
	
			idx=searchArray(nodes,'id',curWay[w]);
			nodeCoords={way:r,lat:nodes[idx].lat,lng:nodes[idx].lon};
			polygon.push(nodeCoords);
			cpt++;
	//log (cpt+": "+nodeCoords.lat+","+nodeCoords.lng);
		}
	}


	var cpt=polygon.length; var sumLng=0; var sumLat=0;
	for (var i=0; i<polygon.length; i++) {
			sumLng+=polygon[i].lng;
			sumLat+=polygon[i].lat;
	}
	var exoc={lat:sumLat/cpt,lng:sumLng/cpt};

	log(exoc);


	var markers=[]; var dot;
	var markerImage = new google.maps.MarkerImage(      "img_handle.png",
                                                         new google.maps.Size(11,11),
                                                         null,
                                                         new google.maps.Point(5,5)
                                                 );
	
	
	
	var dists=0; var dist=0; var highDist=0; var lowDist=9999999999999999;
	var highRadius=0; var lowRadius=lowDist; var radiuss=0;
	for (var i=0; i<polygon.length; i++) {
		j=i+1; if (j==polygon.length) j=0;
			dist=distance(polygon[i],polygon[j]);
			radius=distance(exoc,polygon[i]);
	log(i+": ("+polygon[i].lng+","+polygon[i].lat+") "+dist);
			if (dist>highDist) { highDist=dist; log("******************"); }
			if (dist<lowDist) lowDist=dist;
			if (radius>highRadius) highRadius=radius;
			if (radius<lowRadius) lowRadius=radius;
			dists+=dist;
			radiuss+=radius;


    dot=new google.maps.LatLng(polygon[i].lat,polygon[i].lng);
    markers[i] = new google.maps.Marker({
                                        position:           dot,
                                        map:                map,
                                        icon:               markerImage,
                                        raiseOnDrag:        false,
                                        draggable:          false
                                        });

	}
	var distsAvg=dists/cpt;
	var radiusAvg=radiuss/cpt;



		//log(distance(nodes[0],nodes[420]));
		log (cpt);
		log ("Dists: "+dists);
		log ("DistsAvg: "+distsAvg);
		log ("HighDist: "+highDist);
		log ("Lowdist: "+lowDist);
		log ("HighRadius: "+highRadius);
		log ("LowRadius: "+lowRadius);
		log ("RadiusAvg: "+radiusAvg);

}

