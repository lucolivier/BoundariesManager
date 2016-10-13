

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

function arrayIdSearch(array,id) {
	for (var i=0; i<array.length; i++) {
		if (array[i].id==id) return i;
	}
	return -1;
}

function drawPolygon() {
	//log(bound);
	
	elmts=bound.elements;
	var nodes=new Array();
	var ways=new Array();
	var relation;
	for (var i=0; i<elmts.length; i++) {
		if (elmts[i].type=='node') {
			//nodes[elmts[i].id]={lat:elmts[i].lat,lon:elmts[i].lon};
			nodes.push({id:elmts[i].id,lat:elmts[i].lat,lon:elmts[i].lon});
		} else if (elmts[i].type=='way') {
			//ways[elmts[i].id]=elmts[i].nodes;
			ways.push({id:elmts[i].id,nodes:elmts[i].nodes});
		} else if (elmts[i].type=='relation') {
			relation=elmts[i].members;
		}
	}

	log(ways);
	log(relation);
	log("----------");

	polygon=new Array();

	for (var i=0; i<relation.length; i++) {
		if (relation[i].type=="way") {
			item=arrayIdSearch(ways,relation[i].ref);
			if (item!=-1) {
				way=ways[item];
// 				way.start=nodes[0].id;
// 				way.end=nodes[way.nodes.length-1].id;
				log(relation[i].ref+": "+way.nodes[0]+","+way.nodes[way.nodes.length-1]);
				//log(ways[item]);
			} else {
				log(i+": ref not found: "+relation[i].ref);
			}
		}
	}
	log(ways);

	log("----------");

	var idx=0; var type=1;
	while (ways.length!=0) {
		way=ways[idx];
		if (type==1) {
			startIdx=0;
			endIdx=way.nodes.length-1;
		} else {
			startIdx=way.nodes.length-1;
			endIdx=0;
		}
log(way.id+": "+way.nodes[startIdx]+","+way.nodes[endIdx]);

		for (var p=startIdx; p<=endIdx; p+=type) {
			dot=arrayIdSearch(nodes,way.nodes[p]);
			if (dot!=-1) {
				polygon.push(nodes[dot]);
			} else {
				log(p+": dot not found: "+way.nodes[p]);
			}
		}
		
		id=way.id;
		endId=way.nodes[endIdx];
		ways.splice(idx,1);
		type=0; idx=-1;
		for (var k=0; k<ways.length; k++) {
			if (ways[k].nodes[0]==endId) { type=1; idx=k; break; }
		}
		if (idx==-1) {
			if (ways.length==0) break;
			for (var k=0; k<ways.length; k++) {
				if (ways[k].nodes[ways[k].nodes.length-1]==endId) { type=-1; idx=k; break; }
			}
			if (idx==-1) {
				log("end not found for "+id);
				break;
			}
		}
	}
	
	log("----------");
	log(polygon);

	drawPolygonName(polygon,"black");
	drawPolygonName(nodes,"red");
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

