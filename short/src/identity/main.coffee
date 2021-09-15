import * as THREE from '/js/three.module.js'
import { TWEEN }  from '/js/jsm/libs/tween.module.min.js'
# import { CSS3DRenderer, CSS3DSprite } from '/js/jsm/renderers/CSS3DRenderer.js'
# import { WebGLRenderer } from '/js/jsm/renderers/WebGLRenderer.js'

group = camera = scene = renderer = controls = undefined

particlesTotal = 64;
positions = [];
objects = [];
current = 0;

class SpriteMulti extends THREE.Sprite
    constructor: (material)->
        super(material)
        @type = 'Sprite'
        _geometry = new THREE.BufferGeometry();
        s = 1.0 / 8.0;
        x = Math.random()*8|0;
        y = Math.random()*8|0;
        float32Array = new Float32Array( [
             -0.5, -0.5, 0, (x+0)*s, (y+0)*s,
              0.5, -0.5, 0, (x+1)*s, (y+0)*s,
              0.5,  0.5, 0, (x+1)*s, (y+1)*s,
             -0.5,  0.5, 0, (x+0)*s, (y+1)*s
        ] );
        interleavedBuffer = new THREE.InterleavedBuffer( float32Array, 5 );
        _geometry.setIndex( [ 0, 1, 2,  0, 2, 3 ] );
        _geometry.setAttribute( 'position', new THREE.InterleavedBufferAttribute( interleavedBuffer, 3, 0, false ) );
        _geometry.setAttribute( 'uv', new THREE.InterleavedBufferAttribute( interleavedBuffer, 2, 3, false ) );
        @geometry = _geometry
        @material = material
        @center = new THREE.Vector2( 0.5, 0.5 )

init = ->
    
    console.log("Init")
    camera = window.camera = new THREE.PerspectiveCamera( 90, window.innerWidth / window.innerHeight, 200, 5000 )
    camera.position.set( 0, 0, 1000 )
    camera.lookAt( 0, 0, 0 )

    scene = new THREE.Scene()
    scene.fog = new THREE.Fog 0x111111, 1000, 2000
    # scene.fog = new THREE.FogExp2( 0x000000, 0.00008 )
   
    group = new THREE.Group()
    
    image = document.createElement 'img'

    map      = new THREE.TextureLoader().load '/img/glyphs_128x128.png'
    material = new THREE.SpriteMaterial { map: map, color: 0xFFFFFF }

    ss = 128
    ts = 128
    for i in [0..particlesTotal]
        sprite = new SpriteMulti material
        x = Math.random() - 0.5;
        y = Math.random() - 0.5;
        z = Math.random() - 0.5;
        sprite.position.set x, y, z
        sprite.position.normalize()
        sprite.position.multiplyScalar Math.random()*250 + 750
        sprite.scale.set 64.0, 64.0, 1.0
        group.add sprite
        objects.push sprite

    line_mat  = new THREE.LineBasicMaterial color: 0x3f3f3f
    for i in [0..4]
        # line_geom = new THREE.BufferGeometry()
        points = []
        for i in [0..4]
            k = Math.random()*particlesTotal|0
            points.push objects[k].position

        # line_geom.setAttribute 'position', new THREE.Float32BufferAttribute(points, 3)
        spline = new THREE.CatmullRomCurve3 points
        samples = spline.getPoints points.length * 15
        line_geom = new THREE.BufferGeometry().setFromPoints samples

        line = new THREE.Line line_geom, line_mat
        group.add line

    scene.add group

    renderer = new THREE.WebGLRenderer alpha: true
    renderer.setSize window.innerWidth, window.innerHeight
    
    document.getElementById('three').appendChild( renderer.domElement )
    renderer.setPixelRatio window.devicePixelRatio
    renderer.setSize window.innerWidth, window.innerHeight
    window.addEventListener 'resize', onWindowResize


onWindowResize = ->
    camera.aspect = window.innerWidth / window.innerHeight
    camera.updateProjectionMatrix()
    renderer.setSize window.innerWidth, window.innerHeight


window.rotate_scene = (x=0, y=0)->

    r = {v:0.0}
    wx = new THREE.Vector3 1.0, 0.0, 0.0
    wy = new THREE.Vector3 0.0, 1.0, 0.0
    
    t1 = new TWEEN.Tween(r)
      .to({v: 0.05}, 500 )
      # .easing( TWEEN.Easing.Exponential.InOut )
      .onUpdate((o)=>
        group.rotateOnWorldAxis(wx, x*o.v)
        group.rotateOnWorldAxis(wy, y*o.v)
      )

    t2 = new TWEEN.Tween(r)
      .to({v: 0.0}, 500 )
      # .easing( TWEEN.Easing.Exponential.InOut )
      .onUpdate((o)=>
        group.rotateOnWorldAxis(wx, x*o.v)
        group.rotateOnWorldAxis(wy, y*o.v)
      )
    t1.chain(t2)
    t1.start()


###
transition = ->
    
    offset = current * particlesTotal * 3
    duration = 20000

    for i in [0..particlesTotal]
      object = objects[ i ];
      new TWEEN.Tween( object.position )
        .to( {
          x: positions[ j*3 ],
          y: positions[ j*3 + 1 ],
          z: positions[ j*3 + 2 ]
        }, Math.random() * duration + duration )
        .easing( TWEEN.Easing.Exponential.InOut )
        .start();

    new TWEEN.Tween( this )
      .to( {}, duration * 3 )
      .onComplete( transition )
      .start();

    current = ( current + 1 ) % 4;
###


animate = ->
    requestAnimationFrame animate
    TWEEN.update()
    # controls.update();
    # const time = performance.now();
    # for ( let i = 0, l = objects.length; i < l; i ++ ) {
    #     const object = objects[ i ];
    #     const scale = Math.sin( ( Math.floor( object.position.x ) + time ) * 0.0002 ) * 0.3 + 1;
    #     object.scale.set( scale, scale, scale );
    # }
    renderer.render scene, camera


init()
animate()
