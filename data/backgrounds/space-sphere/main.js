/**
 * Luigi Mannoni (http://luigimannoni.com)
 * Twitter: @mashermack
 * More experiments on:
 * Codepen:  https://codepen.io/luigimannoni
 * Github:   https://github.com/luigimannoni/luigimannoni.github.io
 *
 * Music:    https://soundcloud.com/chloe-orin
 * Three.js: https://github.com/mrdoob/three.js
 *
 */

var audioCtxCheck = window.AudioContext || window.webkitAudioContext;
// if (!audioCtxCheck) {
//   document.getElementById('warning').style.display = 'block';
//   document.getElementById('loading').style.display = 'none';
// }
const el = document.createElement('img');

var AudioUtils = (function () {
  'use strict';

  var audioCtx = null
    , analyser = null
    , dataArray = null
    , source = null
    , loadbar = document.getElementById('loading-bar');

  init();

  var services = {
    getTimeData: getTimeData,
    getFrequencyData: getFrequencyData,
    requestTrack: requestTrack,
    stopTrack: stopTrack,
    getVolumeAvg: getVolumeAvg,
    getMental: getMental,
  };
  return services;


  // Service functions ////////////////////////////////

  function init() {

    // audioCtx = new (window.AudioContext || window.webkitAudioContext)(); // define audio context
    // analyser = audioCtx.createAnalyser();
    // analyser.fftSize = 256;

    // var bufferLength = analyser.fftSize;
    // dataArray = new Uint8Array(bufferLength);

  }

  function getTimeData() {
    analyser.getByteTimeDomainData(dataArray);
    var data = dataArray;
    return data;
  }

  function getFrequencyData() {
    analyser.getByteFrequencyData(dataArray);
    var data = dataArray;
    return data;
  }

  function getVolumeAvg() {
    var volumeAvg = 0;
    var data = getFrequencyData();

    for (var i = 0; i < 128; i++) { // Get the volume from the first 128 bins
      volumeAvg += data[i];
    }

    return volumeAvg;
  }

  function getMental() {
    var volumeAvg = getVolumeAvg();
    return (Math.min(Math.max((Math.tan((volumeAvg / (255 * 128) * 1.8)) * 0.5)), 2)) * 100;
  }

  function requestTrack(_file, _loop) {
    stopTrack();


    // Clean
    // source = audioCtx.createBufferSource();
    // source.connect(analyser);
    // analyser.connect(audioCtx.destination);

    var loopSettings = _loop || false;

    var request = new XMLHttpRequest();
    var streamUrl = 'http://dev.luigimannoni.com/codepen/' + _file;

    request.open('GET', streamUrl, true);
    request.responseType = 'arraybuffer';

    request.onload = function (e) {
      // audioCtx.decodeAudioData(
      //   request.response,
      //   function (buffer) {
      //     var audioBuffer = buffer;

      //     source.buffer = audioBuffer;
      //     source.loop = loopSettings;

      //     source.start(0.0);
      //   },

      //   function (buffer) {
      //   }
      // );
    }

    request.onprogress = function (e) {

      if (e.lengthComputable) {
        var perc = (e.loaded / e.total) * 100;
        loadbar.style.width = perc + '%';
      }

    }

    request.onloadstart = function (e) {
      document.getElementById('loading').style.display = 'block';
    }

    request.onloadend = function (e) {
      document.getElementById('loading').style.display = 'none';
    }

    request.send();
  }

  function stopTrack() {
    try {
      source.stop();
    } catch (e) {
    }
  }

})();

// AudioUtils.requestTrack('yYZjjV/magritte.ogg', true);
// Since I suck at trigonometry I'll just convert radii into degrees.
function deg2rad(_degrees) {
  return (_degrees * Math.PI / 180);
}

/**
 * WebGL Logic
 */

(async () => {
  var controls;
  var scene = new THREE.Scene();
  var camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 10000);
  var innerColor = 0xff0000,
    outerColor = 0xff9900;
  var innerSize = 32,
    outerSize = 64;

  var renderer = new THREE.WebGLRenderer({ antialias: true });
  renderer.setClearColor(0x000000, 0); // background

  renderer.setSize(window.innerWidth, window.innerHeight);
  document.body.appendChild(renderer.domElement);

  controls = new THREE.TrackballControls(camera);
  controls.noPan = true;
  controls.minDistance = 120;
  controls.maxDistance = 650;
  //
  var imageLoader = new LuminosTextureLoader();
  imageLoader.setCrossOrigin('*');
  // Mesh
  var group = new THREE.Group();
  scene.add(group);

  // Lights
  var light = new THREE.AmbientLight(0x404040); // soft white light
  scene.add(light);

  var directionalLight = new THREE.DirectionalLight(0xffffff, 1);
  directionalLight.position.set(0, 128, 128);
  scene.add(directionalLight);

  // Skybox
  var geometry = new THREE.BoxGeometry(5000, 5000, 5000);
  var materialArray = [];
  var directions = ['right1', 'left2', 'top3', 'bottom4', 'front5', 'back6'];
  for (var d of directions) {
    let image = await imageLoader.load('backgrounds://space-sphere/images/bluenebula1024_' + d + '.png');
    materialArray.push(new THREE.MeshBasicMaterial({
      map: image,
      side: THREE.BackSide
    }));
  }
  // for (var i = 0; i < 6; i++) {

  // }
  var material = new THREE.MeshFaceMaterial(materialArray);
  var skybox = new THREE.Mesh(geometry, material);
  scene.add(skybox);

  // Sun
  var uniforms = {
    time: { type: "f", value: 1.0 },
    scale: { type: "f", value: 0.05 }
  };
  var star = new THREE.Mesh(
    new THREE.SphereGeometry(innerSize, 32, 32),
    new THREE.ShaderMaterial({
      uniforms: uniforms,
      vertexShader: document.getElementById('vertexNoise').textContent,
      fragmentShader: document.getElementById('fragmentNoise').textContent
    })
  );

  // scene.add(star);

  var glow = new THREE.Mesh(
    new THREE.SphereGeometry(innerSize + 2, 32, 32),
    new THREE.ShaderMaterial({
      uniforms: {
        "c": { type: "f", value: 1 },
        "p": { type: "f", value: 6 },
        glowColor: { type: "c", value: new THREE.Color(0xff3300) },
        viewVector: { type: "v3", value: camera.position }
      },
      vertexShader: document.getElementById('vertexGlow').textContent,
      fragmentShader: document.getElementById('fragmentGlow').textContent,
      side: THREE.BackSide,
      blending: THREE.AdditiveBlending,
      transparent: true,
      alphaTest: 0.2,
    })
  );

  // scene.add(glow);

  var sphereOuter = new THREE.Group();
  var icosahedronGeometry = new THREE.IcosahedronGeometry(outerSize, 3);

  // materials
  var materials = [],
    matCopy = [];


  for (var i = 0; i < 89; i++) {
    materials.push(new THREE.MeshPhongMaterial({ color: innerColor, shading: THREE.FlatShading, side: THREE.DoubleSide, transparent: true, opacity: 0.8 }));
    matCopy.push(new THREE.MeshPhongMaterial({ color: innerColor, shading: THREE.FlatShading, side: THREE.DoubleSide, transparent: true, opacity: 0.8 }));
  };

  // assign material to each face
  for (var i = 0; i < icosahedronGeometry.faces.length; i++) {
    icosahedronGeometry.faces[i].materialIndex = THREE.Math.randInt(0, materials.length - 1);
  }

  icosahedronGeometry.sortFacesByMaterialIndex(); // optional, to reduce draw calls




  // Sphere Wireframe Outer
  var icosahedronOuter = new THREE.Mesh(
    icosahedronGeometry,
    new THREE.MeshFaceMaterial(materials)
  );
  /*var icosahedronOuter = new THREE.Mesh(
    icosahedronGeometry,
    new THREE.MeshLambertMaterial({
      color: outerColor,
      ambient: outerColor,
      wireframe: false,
      transparent: true,
      shading: THREE.FlatShading,
      opacity: 1,
      //alphaMap: imageLoader.load( '//luigimannoni.github.io/experiments/spacesphere-webgl/javascripts/alphamap.jpg' ),
      shininess: 0
    })
  );*/
  sphereOuter.add(icosahedronOuter);

  // The icosahedron helper
  var icoEdgeHelper = new THREE.EdgesHelper(icosahedronOuter, innerColor);
  icoEdgeHelper.material.linewidth = 0.5;
  icoEdgeHelper.material.opacity = 0.2;
  icoEdgeHelper.material.transparent = true;
  // scene.add( icoEdgeHelper ); // Needs to stay outside

  // Clone geometry
  var icoGeometryBuffer = new THREE.BufferGeometry();
  icoGeometryBuffer.fromGeometry(icosahedronOuter.geometry);

  let particlesImg = await imageLoader.load('backgrounds://space-sphere/images/particletexture.png')
  // Particles Inner
  var particlesInner = new THREE.Points(icoGeometryBuffer, new THREE.PointsMaterial({
    size: 2,
    color: innerColor,
    map: particlesImg,
    transparent: true,
  })
  );
  sphereOuter.add(particlesInner);
  // scene.add(sphereOuter);

  // Starfield
  var geometry = new THREE.Geometry();
  for (i = 0; i < 5000; i++) {
    var vertex = new THREE.Vector3();
    vertex.x = Math.random() * 2000 - 1000;
    vertex.y = Math.random() * 2000 - 1000;
    vertex.z = Math.random() * 2000 - 1000;
    geometry.vertices.push(vertex);
  }
  particlesImg = await imageLoader.load('backgrounds://space-sphere/images/particletextureshaded.png');
  console.log("particlesImg", particlesImg)
  var starField = new THREE.Points(geometry, new THREE.PointsMaterial({
    size: 10,
    color: 0xffffff,
    map: particlesImg,
    transparent: true
  })
  );
  scene.add(starField);


  camera.position.z = -110;

  var time = new THREE.Clock();

  var render = function () {

    renderer.render(scene, camera);
    var innerShift = Math.abs(Math.cos(((time.getElapsedTime() + 2.5) / 20))) / 10;
    var outerShift = Math.abs(Math.cos(((time.getElapsedTime() + 5) / 10)));
    var superShift = Math.abs(Math.cos(((time.getElapsedTime() + 5) / 20)));

    if (audioCtxCheck) {
      // Audio Context is supported
      var mental = AudioUtils.getMental(); //(Math.min(Math.max((Math.tan(AudioUtils.volumeHi/6500) * 0.5)), 2));

      uniforms.time.value += 0.02 + (mental * 0.1);

      sphereOuter.scale.set(1 + (mental * 0.3), 1 + (mental * 0.3), 1 + (mental * 0.3));
      icoEdgeHelper.material.color.setHSL(superShift, 1, mental);
      particlesInner.material.color.setHSL(superShift, 1, mental);
      var streamData = AudioUtils.getTimeData();
      for (var i = 0; i < materials.length; i++) {
        materials[i].color.setHSL(superShift, 1 / 255 * streamData[i], 0.5);
        materials[i].opacity = 1 / 255 * streamData[i];
      }


      if (mental > 0.7) {
        for (var i = 0; i < materials.length; i++) {
          var applyThis = THREE.Math.randInt(0, materials.length - 1);
          icosahedronOuter.material.materials[i] = matCopy[applyThis];
        }
      }


    }
    else {
      // Fallback for no support for AudioContext
      uniforms.time.value += 0.02;

      for (var i = 0; i < materials.length; i++) {
        materials[i].color.setHSL(innerShift, 1, 0.5);
        materials[i].opacity = outerShift;
      }
      icoEdgeHelper.material.color.setHSL(innerShift, 1, 0.5);
      particlesInner.material.color.setHSL(innerShift, 1, 0.5);
    }

    directionalLight.position.x = Math.cos(time.getElapsedTime() / 0.5) * 128;
    directionalLight.position.y = Math.cos(time.getElapsedTime() / 0.5) * 128;
    directionalLight.position.z = Math.sin(time.getElapsedTime() / 0.5) * 128;

    skybox.rotation.y -= 0.0005;
    starField.rotation.y -= 0.002;
    sphereOuter.rotation.x += 0.001;
    sphereOuter.rotation.z += 0.001;

    controls.update();

    requestAnimationFrame(render);
  };

  render(); // Ciao


  // Mouse and resize events
  window.addEventListener('resize', onWindowResize, false);

  function onWindowResize() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
  }
})();
