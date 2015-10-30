/**
 * 
 */

var geoM=angular.module('geo_module');

geoM.factory('$map',function(){
	var map= new ol.Map({
		  target: 'map',
		  layers: [],
		  view: new ol.View({
		    center: ol.proj.transform(
		        [0, 40], 'EPSG:4326', 'EPSG:3857'),
		    zoom: 5
		  })
		});
	
	
	return map;
});

geoM.factory('baseLayer', function() {
	
	var baseLayersConf={
					    "Default": {
					        "OpenStreetMap": {
					            "type": "TMS",
					            "category":"Default",
					            "label": "OpenStreetMap",
					            "layerURL": "http://tile.openstreetmap.org/",
					            "layerOptions": {
					                "type": "png",
					                "displayOutsideMaxExtent": true
					            }
					        },
					        "OSM": {
					            "type": "OSM",
					            "category":"Default",
					            "label":"OSM"
					        }
					    }
					};
  return baseLayersConf;
});


geoM.service('layerServices', function(baseLayer, $map,$http) {
	this.selectedBaseLayer;  //the selected base layer
	this.selectedBaseLayerOBJ;
	this.loadedLayer={};
	this.loadedLayerOBJ={};
	
	this.isSelectedBaseLayer=function(layer){
		return angular.equals(this.selectedBaseLayerOBJ, layer);
	}
	
	this.layerIsLoaded=function(layer){
		return (this.loadedLayerOBJ[layer.layerId]!=undefined);
	}

	this.alterBaseLayer = function(layerConf) {
		console.log("alterBaseLayer", layerConf);
		var layer=this.createLayer(layerConf,true);
		if(layer!=undefined){
			$map.removeLayer(this.selectedBaseLayer);
			this.selectedBaseLayer=layer;
			this.selectedBaseLayerOBJ=layerConf;
			$map.addLayer(this.selectedBaseLayer);
			$map.render();
		}
		
	}

	this.toggleLayer = function(layerConf) {
		console.log("addLayer");
		if(this.loadedLayer[layerConf.layerId]!=undefined){
			$map.removeLayer(this.loadedLayer[layerConf.layerId]);
			delete this.loadedLayer[layerConf.layerId];
			delete this.loadedLayerOBJ[layerConf.layerId];
		}else{
			var layer=this.createLayer(layerConf,false);
			if(layer!=undefined){
				this.loadedLayer[layerConf.layerId]=layer;
				this.loadedLayerOBJ[layerConf.layerId]=layerConf;
				$map.addLayer(layer);
				$map.render();
			}
		}
	}
	
	
	this.createLayer=function(layerConf,isBase){
		
		var tmpLayer;
		var zIndex=0;
		if(isBase){
			zIndex=-1;
		}
		
		switch (layerConf.type) {
		case 'WMS':
			tmpLayer = new ol.layer.Tile({
				zIndex : zIndex,
				source : new ol.source.TileWMS(/** @type {olx.source.TileWMSOptions} */
				({
					url : layerConf.layerURL,
					params : JSON.parse(layerConf.layerParams),
					options :JSON.parse(layerConf.layerOptions)
				}))
			});
			break;
		case 'WFS': // TODO test if works
			var vectorSource = new ol.source.Vector({
				  url: layerConf.layerURL,
				  format: new ol.format.GeoJSON(),
//				  options : JSON.parse(layerConf.layerOptions)
				});
			
		
			tmpLayer = new ol.layer.Vector({
				  source: vectorSource,
				});
			
			
				
			break;
		case 'TMS': // TODO check if work
			
			var options=(layerConf.layerOptions instanceof Object)? layerConf.layerOptions : JSON.parse(layerConf.layerOptions);
			tmpLayer = new ol.layer.Tile({
				zIndex : zIndex,
				source : new ol.source.XYZ({
					tileUrlFunction : function(coordinate) {
						if (coordinate == null) {
							return "";
						}
						var z = coordinate[0];
						var x = coordinate[1];
						// var y = (1 << z) -coordinate[2] - 1;
						var y = -coordinate[2] - 1;
						return layerConf.layerURL + '' + z + '/' + x + '/' + y + '.'+ options.type;
					},

				})
			});
			break;
		case 'OSM':
			tmpLayer = new ol.layer.Tile({
				source : new ol.source.MapQuest({
					layer : 'osm'
				}),
				zIndex : zIndex
			});
			break;
		default:
			console.error('Layer type [' + layerConf.type + '] not supported');
			break;
		}
		
		return tmpLayer;
	}
	
	
	 
})



geoM.service('geoReportUtils',function(baseLayer,$map){
	
	 this.osm_getTileURL= function(bounds) {
			var res = $map.getResolution();
			var x = Math.round((bounds.left - this.maxExtent.left) / (res * this.tileSize.w));
			var y = Math.round((this.maxExtent.top - bounds.top) / (res * this.tileSize.h));
			var z = $map.getZoom();
			var limit = Math.pow(2, z);

			if (y < 0 || y >= limit) {
				console.log("####################### implementare  OpenLayers.Util.getImagesLocation() + ''404.png'")
//				return OpenLayers.Util.getImagesLocation() + "404.png";
			} else {
				x = ((x % limit) + limit) % limit;
				return this.url + z + "/" + x + "/" + y + "." + this.type;
			}
		}
	
})
