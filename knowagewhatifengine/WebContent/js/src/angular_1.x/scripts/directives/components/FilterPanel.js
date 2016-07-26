/*
 * Knowage, Open Source Business Intelligence suite
 * Copyright (C) 2016 Engineering Ingegneria Informatica S.p.A.
 *
 * Knowage is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Knowage is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
(function() {
	

angular.module('filter_panel',['sbiModule'])
.directive('filterPanel',function(sbiModule_config){
	return{
		restrict: "E",
		replace: 'true',
//		templateUrl: '/knowagewhatifengine/html/template/main/filter/filterPanel.html',
		templateUrl: function(){
	    	 return sbiModule_config.contextName+'/html/template/main/filter/filterPanel.html';
	    	  
	      },
		controller: filterPanelController
	}
});

function filterPanelController($scope, $timeout, $window, $mdDialog, $http, $sce, sbiModule_messaging, sbiModule_restServices, sbiModule_translate) {
	
	var visibleSelected = [];
	var visibleSelectedTracker = [];
	var filterFather;
	var h;
	var m;
	var oldSelectedFilter="";
	var hlght = false;
	var selectedFlag = false;
	
	var cutArray = [12, 11, 10, 9, 6]; //array with maximum lengths for card
	
	var typeMsgWarn =sbiModule_translate.load('sbi.common.warning');
	$scope.loadingFilter = true;
	$scope.filterPanelEmpty = sbiModule_translate.load('sbi.olap.execution.table.filter.empty');
	
	angular.element(document).ready(function() {
		$scope.sendMdxQuery('null');
		
	});
	
	
	$scope.clearLoadedData = function(name){
		for(var i=0; i< $scope.dataPointers.length; i++){
			if(name == $scope.dataPointers[i]){
				$scope.dataPointers.splice(i,1);
				$scope.loadedData.splice(i,1)
				break;
			}
		}
		var visibleSelected = [];
		var visibleSelectedTracker = [];
	};
	
	clearSelectedList = function(){
		for(var i=0;i< visibleSelected.length;i++){
			if(visibleSelected[i].id.indexOf(filterFather) == -1){
				visibleSelected.splice(i,1);
			}
		}
		for(var i=0;i<visibleSelectedTracker.length;i++){
			if(visibleSelectedTracker[i].id == undefined || visibleSelectedTracker[i].id.indexOf(filterFather) == 1){
				visibleSelectedTracker.splice(i,1);
			}
		}
	};
	
	getVisibleService = function(un,axis){
		var toSend = {
			'hierarchy':un,
			'axis':axis
		}
		var encoded = encodeURI('1.0/hierarchy/getvisible?SBI_EXECUTION_ID='+ JSsbiExecutionID);
		sbiModule_restServices.promisePost
		(encoded,"",toSend)
		.then(function(response) {
			visibleSelected = response.data;
		}, function(response) {
			//sbiModule_messaging.showErrorMessage("An error occured during search for filter", 'Error');
		});
	};
	
	/**
	 * Dialogs  
	 **/
	$scope.openFiltersDialogAsync = function(ev, filter, node, index) {
		
		$scope.clearLoadedData(filter.uniqueName);
		visibleSelected = [];//check it
		visibleSelectedTracker = [];//check it
		$scope.searchText = "";
		$scope.loadingFilter = true;
		var x = {name:'Waiting...'};
		$scope.data = [];
		$scope.data.push(x);
		
		if(filter.axis > -1)
			getVisibleService(filter.uniqueName,filter.axis);
		
		$scope.filterDialogToolbarName = filter.caption;
		$scope.filterAxisPosition = index;
		$scope.activeaxis = filter.axis;
		filterFather = filter.selectedHierarchyUniqueName;
		h = filter.uniqueName;

			$scope.getHierarchyMembersAsynchronus(filterFather, filter.axis, null,filter.id);
			$scope.dataPointers.push(filterFather);

		
		$scope.showDialog(ev,$scope.filterDial);

		$scope.loadingFilter = false;
	};
	
	/**
	 *Tree functionalities 
	 **/
	$scope.expandTreeAsync = function(item){
		$scope.getHierarchyMembersAsynchronus(filterFather,$scope.activeaxis,item.uniqueName,item.id);	
	};
	
	expandAsyncTree = function(d,dput,id){
		for(var i = 0; i< d.length; i++){
			if(d[i].id == id){
				d[i]["children"] = dput;
				d[i]["collapsed"]=true;
				break;
			}
			else{
				if(d[i].children != undefined){
					if(!d[i].leaf && d[i].children.length>0){
						expandAsyncTree(d[i].children,dput,id);
					}
				}				
			} 
		}
	};
	
	 /*service for placing member on axis**/
	 $scope.putMemberOnAxis = function(fromAxis,member){
		 $scope.members = [];
		 var toSend = {
				 'fromAxis':fromAxis,
				 'hierarchy':member.selectedHierarchyUniqueName,
				 'toAxis': member.axis
		 }
		 //var encoded = encodeURI('1.0/axis/'+fromAxis+'/moveDimensionToOtherAxis/'+member.selectedHierarchyUniqueName+'/'+member.axis+'?SBI_EXECUTION_ID='+JSsbiExecutionID);
		 var encoded = encodeURI('1.0/axis/moveDimensionToOtherAxis?SBI_EXECUTION_ID='+JSsbiExecutionID);
		 sbiModule_restServices.promisePost
		 (encoded,"",toSend)
			.then(function(response) {
				$scope.handleResponse(response);
				checkShift();
				//updateFilterTracker();
				if(fromAxis == 1){
					$scope.leftStart = 0;
				}
				if(fromAxis == 0){
					$scope.topStart = 0;
				}
			}, function(response) {
				sbiModule_messaging.showErrorMessage("An error occured while placing member on axis", 'Error');
				
			});	
	}
	
	$scope.searchFilter = function(){		
		hlght = true;
		var toSend = {
			'hierarchy':h,
			'axis': $scope.activeaxis,
			'name': $scope.searchText,
			'showS':$scope.showSiblings
		};
		
		var encoded = encodeURI('1.0/hierarchy/search?SBI_EXECUTION_ID='+ JSsbiExecutionID);
		sbiModule_restServices.promisePost
		(encoded,"",toSend)
		.then(function(response) {
				checkIfExists(response.data);
				$scope.searchSucessText = $scope.searchText.toLowerCase();
		}, function(response) {
			sbiModule_messaging.showErrorMessage("An error occured during search for filter", 'Error');
		});
	};
	
	checkIfExists = function(data){
		var exist = false;
		for(var i = 0; i< $scope.dataPointers.length;i++){
			if($scope.dataPointers[i] == filterFather){
					exist = true;
					$scope.loadedData[i] = data
					$scope.data= $scope.loadedData[i];
					
			}
		}
		if(!exist){
			$scope.data= data;
			$scope.dataPointers.push(filterFather);
		}
			
	};
	
	$scope.getHierarchyMembersAsynchronus = function(hierarchy,axis,node,id){
		var toSend={
			'hierarchy':hierarchy,
			'axis':axis,
			'node':node
		}
		var encoded = encodeURI('1.0/hierarchy/filtertree?SBI_EXECUTION_ID='+ JSsbiExecutionID);
		sbiModule_restServices.promisePost
		(encoded,"",toSend)
		.then(function(response) {
				//$scope.handleResponse(response)
			  if(node!=null){
				  var shouldSearchVisible = true;
				  expandAsyncTree($scope.data,response.data, id);
					
				  for(var j = 0; j< visibleSelectedTracker.length;j++){
					if(visibleSelectedTracker[j].id == h && visibleSelectedTracker[j].selected.length > 0)
						shouldSearchVisible= false;
					}
			  }				  
			  else{
				  checkIfExists(response.data);
			  }
			  
		}, function(response) {
			sbiModule_messaging.showErrorMessage("An error occured while getting hierarchy members", 'Error');	
		});	
	}
	
	//Called if row/column dimension is unselected
	removeUnselected = function(id){
		for(var i=0;i<visibleSelected.length;i++){
			if(id == visibleSelected[i].id){
				visibleSelected.splice(i,1);	
			}
		}
		
	};
	
	removeChildren = function(){
		for(var i=0; i<visibleSelected.length;i++){
			if(visibleSelected[i].children != undefined){
				delete visibleSelected[i].children;
			}
			if(visibleSelected[i].collapsed != undefined){
				delete visibleSelected[i].collapsed;
			}
		}
	};
	
	$scope.selectFilter = function(item){
		selectedFlag = true;
		oldSelectedFilter = angular.copy($scope.filterSelected[$scope.filterAxisPosition]);//ex:$scope.filterAxisPosition
		h = $scope.filterCardList[$scope.filterAxisPosition].uniqueName;
		m = item.uniqueName;
		$scope.filterSelected[$scope.filterAxisPosition].caption = item.name;
		$scope.filterSelected[$scope.filterAxisPosition].uniqueName = item.uniqueName;
	};
	
	$scope.closeFiltersDialog = function() {
		
		if(selectedFlag){
			if(oldSelectedFilter.caption != "..."){
				$scope.filterSelected[$scope.filterAxisPosition].caption = oldSelectedFilter.caption;
				$scope.filterSelected[$scope.filterAxisPosition].uniqueName = oldSelectedFilter.uniqueName;
			}				
			else{
				$scope.filterSelected[$scope.filterAxisPosition].caption = "...";
				$scope.filterSelected[$scope.filterAxisPosition].uniqueName = "";
			}				
			
			selectedFlag = false;
		}
		$scope.searchText = "";
		hlght = false;
		$mdDialog.hide();		
	}
	
	$scope.filterDialogSave = function(){
		if($scope.activeaxis == -1)
			filterSlice();
		else
			filterPlaceMemberOnAxis();
		
		selectedFlag = false;
		$mdDialog.hide();
	}
	
	filterSlice = function(){
		var toSend = {
			'hierarchy':filterFather,
			'member':m,
			'multi':false
		};
		
		if(filterFather != undefined && m!= undefined){
			var encoded = encodeURI('1.0/hierarchy/slice?SBI_EXECUTION_ID='+ JSsbiExecutionID);
			sbiModule_restServices.promisePost
			(encoded,"",toSend)
			.then(function(response) {
				  $scope.selectedVersion=response.data.modelConfig.actualVersion;
				  $scope.table = $sce.trustAsHtml(response.data.table);
				  $scope.filterSelected[$scope.filterAxisPosition].visible = true;//ex:$scope.filterAxisPosition
			}, function(response) {
				sbiModule_messaging.showErrorMessage("An error occured", 'Error');
			});	
		}
	};
	
	filterPlaceMemberOnAxis = function(){
		removeChildren();
		clearSelectedList();
		console.log("from pmona"+visibleSelected);
		var encoded = encodeURI('1.0/axis/'+ $scope.activeaxis+ '/placeMembersOnAxis?SBI_EXECUTION_ID='+ JSsbiExecutionID);
		sbiModule_restServices.promisePost
		(encoded,"",visibleSelected)
		.then(function(response) {
			 visibleSelected = [];			
			 $scope.handleResponse(response);
		}, function(response) {
			sbiModule_messaging.showErrorMessage("An error occured while placing member on axis", 'Error');
			
		});
	};
		
	//Called when checkbox is clicked in row/column on front end
	$scope.checkboxSelected = function(data){
		data.visible = !data.visible;
		if(data.visible){
			visibleSelected.push(data);
		}
		else{
			removeUnselected(data.id)
		}
	}
	
	 /* service for moving hierarchies* */
	$scope.moveHierarchies = function(axis, hierarchieUniqeName, newPosition,
			direction, member) {
		var toSend ={ 
				'axis':axis,
				'hierarchy': hierarchieUniqeName,
				'newPosition':newPosition,
				'direction':direction
		}
		var encoded = encodeURI('1.0/axis/moveHierarchy?SBI_EXECUTION_ID=' + JSsbiExecutionID);
		sbiModule_restServices.promisePost(
				encoded, "", toSend)
				.then(
						function(response) {
							$scope.handleResponse(response);
						},
						function(response) {
							sbiModule_messaging.showErrorMessage(
									"An error occured while movin hierarchy",
									'Error');
						});
	};
	
	$scope.highlight = function(name){
		if(!hlght)
			return false;
		if(name.toLowerCase().indexOf($scope.searchSucessText.toLowerCase()) > -1)
			return true;
		else
			return false		
	};		
			
	$scope.showHideSearchOnFilters = function(){		
		$scope.showSearchInput = !$scope.showSearchInput;		
	};
	
	$scope.hideAsyncTree = function(item){
		item.collapsed = false;
	};
	
	/**
	 * Drag and drop functionalities start
	 **/	
	$scope.dropTop = function(data, ev) {
		var leftLength = $scope.rows.length;
		var topLength = $scope.columns.length;
		var fromAxis;
		var pa;
		
		if(data!=null){
			pa = data.positionInAxis;
			fromAxis = data.axis;
			
			if(fromAxis == -1){
				$scope.filterSelected[data.positionInAxis].caption ="...";
				$scope.filterSelected[data.positionInAxis].visible =false;
			}				
			
			if(fromAxis!=0){
				if ($scope.draggedFrom == 'left' && leftLength == 1){
					sbiModule_messaging.showWarningMessage(sbiModule_translate.load('sbi.olap.execution.table.dimension.no.enough'), typeMsgWarn);
				}					
				else {
					data.positionInAxis = topLength;
					data.axis = 0;

					$scope.putMemberOnAxis(fromAxis,data);
					
				}
			}
		}
		if(data!= null)
			$scope.clearLoadedData(data.uniqueName);
	};

	
	$scope.dropLeft = function(data, ev) {
		var leftLength = $scope.rows.length;
		var topLength = $scope.columns.length;
		var fromAxis;
		
		if(data !=null){
			fromAxis = data.axis;
			
			if(fromAxis == -1){
				$scope.filterSelected[data.positionInAxis].caption ="...";
				$scope.filterSelected[data.positionInAxis].visible =false;
			}	
			
			if(fromAxis != 1){				
				if ($scope.draggedFrom == 'top' && topLength == 1)
					sbiModule_messaging.showWarningMessage(sbiModule_translate.load('sbi.olap.execution.table.dimension.no.enough'), typeMsgWarn);
				else {
					data.positionInAxis = leftLength;
					data.axis = 1;
					$scope.putMemberOnAxis(fromAxis,data);
				}
				
			}
		}
		if(data!= null)
			$scope.clearLoadedData(data.uniqueName);
	};

	$scope.dropFilter = function(data, ev) {
		var leftLength = $scope.rows.length;
		var topLength = $scope.columns.length;
		var fromAxis;
		
		if(data != null){
			fromAxis = data.axis;
			
			if(data.measure){
				sbiModule_messaging.showWarningMessage(sbiModule_translate.load('sbi.olap.execution.table.filter.no.measure'), typeMsgWarn);
				return null;
			}
			
			if(fromAxis!=-1){			
				
				if ($scope.draggedFrom == 'left' && leftLength == 1)
					sbiModule_messaging.showWarningMessage(sbiModule_translate.load('sbi.olap.execution.table.dimension.no.enough'), typeMsgWarn);
				else if ($scope.draggedFrom == 'top' && topLength == 1)
					sbiModule_messaging.showWarningMessage(sbiModule_translate.load('sbi.olap.execution.table.dimension.no.enough'), typeMsgWarn);
				else {
					data.positionInAxis = $scope.filterCardList.length;
					data.axis = -1;
					
					$scope.putMemberOnAxis(fromAxis,data);
				}
				
				$scope.filterSelected[$scope.filterSelected.length] = {caption:"...",uniqueName:"",visible:false};
			}
		}
		if(data!=null)
			$scope.clearLoadedData(data.uniqueName);
	};

	$scope.dragSuccess = function(df, index) {
		$scope.draggedFrom = df;
		$scope.dragIndex = index;
	};
			
	$scope.openFilters = function(ev) {
		$mdDialog.show($mdDialog.alert().clickOutsideToClose(true).title(
				"Here goes filtering").ok("ok").targetEvent(ev));
	};

	/**
	 * Filter shift if necessary  
	 **/
	$scope.filterShift = function(direction) {

		$scope.filterCardList = shift(direction,$scope.filterCardList);
		$scope.filterSelected = shift(direction,$scope.filterSelected);
	};
	
	shift = function(direction, data){
		var length = data.length;
		var first = data[0];
		var last = data[length-1];
		if(direction == "left"){
			for (var i = 0; i < length; i++) {
				data[i] = data[i + 1];
			}
			data[length - 1] = first;
		}
		else{
			for (var i = length - 2; i >= 0; i--) {
				data[i + 1] = data[i];
			}
			data[0] = last;
		}
		
		return data;
	};
	
	checkShift = function(){
		$scope.shiftNeeded = $scope.filterCardList.length > $scope.numVisibleFilters ? true
				: false;
		
		$scope.topSliderNeeded = $scope.columns.length > $scope.maxCols? true : false;
		
		$scope.leftSliderNeeded = $scope.rows.length > $scope.maxRows? true : false;
	};

	
	$scope.sendMdxQuery = function(mdx) {
		var encoded = encodeURI("1.0/model/?SBI_EXECUTION_ID="+JSsbiExecutionID)
		sbiModule_restServices.promisePost(encoded,"",mdx)
		.then(function(response) {
			$scope.handleResponse(response);
			checkShift();
			$mdDialog.hide();
			$scope.mdxQuery = "";
			
			$scope.sendModelConfig($scope.modelConfig);
			if($scope.modelConfig.whatIfScenario)
				$scope.getVersions();
			axisSizeSetup();
			
		}, function(response) {
			sbiModule_messaging.showErrorMessage("An error occured while sending MDX query", 'Error');
			
		});	
	};
	
	$scope.bgColor = function(){
		if( $scope.searchText == "" || $scope.searchText.length>=  $scope.minNumOfLetters)
			return false;
		else	
			return true;
	};
	
	$scope.cutName = function(name, axis, multi){
		var ind = axis;
		if(multi)
			ind = ind + 2;
		
		ind = ind+1;
		
		var cutProp = cutArray[ind];
		
		if(name == undefined){
			name = oldSelectedFilter.caption;
		}
		
		if(name.length <= cutProp)
			return name;
		else
			return name.substring(0,cutProp)+"...";
		
		
	};
	
	updateFilterTracker = function(){
		var oldSelected = $scope.filterSelected;
		for(var i=0; i<oldSelected.length;i++){			
			for(var j=0; j<$scope.filterCardList.length;j++){
				if(oldSelected[i].uniqueName.indexOf($scope.filterCardList[j].uniqueName)>-1){
					$scope.filterSelected[j] = oldSelected[i];
				}
			}
			
		}
	};
	
	axisSizeSetup = function(){
		var taw = document.getElementById("topaxis").offsetWidth - 66;
		var lah = document.getElementById("leftaxis").offsetHeight - 66;
		var faw = document.getElementById("filterpanel").offsetWidth - 80;
		$scope.maxCols = Math.round(taw/200);
		$scope.maxRows = Math.round(lah/175);
		$scope.numVisibleFilters = Math.round(faw/200);

	};
};
})();