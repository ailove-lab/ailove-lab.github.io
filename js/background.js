import * as THREE from './three.module.js';
import { TWEEN } from './jsm/libs/tween.module.min.js';
import { TrackballControls } from './jsm/controls/TrackballControls.js';
import { CSS3DRenderer, CSS3DSprite } from './jsm/renderers/CSS3DRenderer.js';

let camera, scene, renderer;
let controls;

const particlesTotal = 64;
const positions = [];
const objects = [];
let current = 0;

function init() {
  console.log("Init")

  camera = window.camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 1, 5000 );
  camera.position.set( 0, 0, 1000 );
  camera.lookAt( 0, 0, 0 );

  scene = window.scene = new THREE.Scene();

  const image = document.createElement( 'img' );
  image.addEventListener( 'load', function () {
    let ss = 128; // source sprite size
    let ts = 128; // target sprite size
    for ( let i = 0; i < particlesTotal; i ++ ) {
      let cvs = document.createElement("canvas");
      cvs.width = cvs.height = ts;
      let ctx = cvs.getContext("2d");
      let rx = (Math.random()*8|0)*ss;
      let ry = (Math.random()*8|0)*ss;
      ctx.drawImage(image,rx,ry,ss,ss,0,0,ts,ts);
      const object = new CSS3DSprite(cvs);
      document.body.prepend(cvs);
      
      let h = Math.random()*6.283;
      let v = Math.random()*6.283;
      let r = Math.random()*1000+1000;
      object.position.x = r*Math.sin(h)*Math.cos(v),
      object.position.y = r*Math.sin(h)*Math.sin(v),
      object.position.z = r*Math.cos(h);
      scene.add( object );
      objects.push( object );
    }
    // transition();

  } );
  image.src = '/img/glyphs_128x128.png';

  renderer = new CSS3DRenderer( {alpha: true});
  renderer.setSize( window.innerWidth, window.innerHeight );
  document.getElementById( 'three' ).appendChild( renderer.domElement );

  // controls = new TrackballControls( camera, renderer.domElement );

  window.addEventListener( 'resize', onWindowResize );

}

function onWindowResize() {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize( window.innerWidth, window.innerHeight );
}

window.rotate_scene = function(x=0, y=0) {
  let r = {v:0.0}
  let t1 = new TWEEN.Tween(r)
    .to({v: 0.05}, 500 )
    //.easing( TWEEN.Easing.Exponential.InOut )
    .onUpdate(o=>{
      scene.rotateX(x*o.v);
      scene.rotateY(y*o.v);
    })
  let t2 = new TWEEN.Tween(r)
    .to({v: 0.0}, 500 )
    //.easing( TWEEN.Easing.Exponential.InOut )
    .onUpdate(o=>{
      scene.rotateX(x*o.v);
      scene.rotateY(y*o.v);
    })
  t1.chain(t2);
  t1.start();
}

/*
function transition() {
  const offset = current * particlesTotal * 3;
  const duration = 20000;

  for ( let i = 0, j = offset; i < particlesTotal; i ++, j += 3 ) {
    const object = objects[ i ];
    new TWEEN.Tween( object.position )
      .to( {
        x: positions[ j ],
        y: positions[ j + 1 ],
        z: positions[ j + 2 ]
      }, Math.random() * duration + duration )
      .easing( TWEEN.Easing.Exponential.InOut )
      .start();
  }

  new TWEEN.Tween( this )
    .to( {}, duration * 3 )
    .onComplete( transition )
    .start();

  current = ( current + 1 ) % 4;

}
*/ 

function animate() {
  requestAnimationFrame( animate );
  TWEEN.update();
  // controls.update();
  // const time = performance.now();
  // for ( let i = 0, l = objects.length; i < l; i ++ ) {
  //   const object = objects[ i ];
  //   const scale = Math.sin( ( Math.floor( object.position.x ) + time ) * 0.0002 ) * 0.3 + 1;
  //   object.scale.set( scale, scale, scale );
  // }
  renderer.render( scene, camera );
}

init();
animate();
