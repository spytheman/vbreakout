// Copyright (c) 2019 Delyan Angelov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module main

import rand
import time
import gx
import gl
import gg
import glfw
import math
import freetype

import const (
  GL_SRC_ALPHA
  GL_ONE_MINUS_SRC_ALPHA
)
  
const (
    MaxBricksX = 10
    MaxBricksY = 30
    BrickWidth = 80 // pixels
    BrickHeight = 20 // pixels
    WinWidth = BrickWidth * MaxBricksX
    WinHeight = BrickHeight * MaxBricksY
    TimerPeriod = 16
)

struct Moves {
mut:
    left bool
    right bool
}
struct Paddle {
mut:
    x int
    y int
    speed int
    maxspeed int
    size int // halfsize, from the center till the edges in pixels
    height int
    color gx.Color
    image u32
}

struct Ball {
mut:
    x int
    y int
    radius int
    dx int
    dy int
    color gx.Color
    image u32
}

struct Brick {
mut:
    x int
    y int
    color gx.Color
    image u32
}

struct Game {
mut:
    frames int
    fps int
    moves Moves
    bricks []Brick
    paddle Paddle
    ball Ball
    quit bool

    gg          *gg.GG
    ft          *freetype.Context
    text_config *gx.TextCfg
}

fn ptodo (s string) {
    println('TODO: $s')
}

fn (g mut Game) init_game() {
    rand.seed(time.now().uni)
    g.init_bricks()
    g.text_config = &gx.TextCfg {   color: gx.White,   size: 18,   align: gx.ALIGN_LEFT,   }

    g.paddle.image = gg.create_image( 'assets/paddle.png' )
    g.paddle.color = gx.rgb(0, 127, 0)
    g.paddle.x = WinWidth / 2
    g.paddle.size = 40
    g.paddle.height = 15
    g.paddle.maxspeed = 5
    g.paddle.y = WinHeight - g.paddle.height

    g.ball.color = gx.rgb(255, 255, 0)
    g.ball.dx = 3
    g.ball.dy = 3
    g.ball.radius = 32
    g.ball.image = gg.create_image( 'assets/ball.png' )

    g.quit = false
}

fn (g mut Game) init_bricks() {
    ptodo('init_bricks')
}

fn (g mut Game) run() {
    for {
        g.frames++
        g.move_paddle()
        g.move_ball()
        g.delete_broken_bricks()
        //glfw.post_empty_event()
        if(g.quit) {
            break
        }
        time.sleep_ms(TimerPeriod)
    }
}

fn (g mut Game) move_paddle() {
    g.paddle.speed = 0
    if g.moves.left {
        g.paddle.speed = - g.paddle.maxspeed
    }
    if g.moves.right {
        g.paddle.speed =   g.paddle.maxspeed
    }
    g.paddle.x = g.paddle.x + g.paddle.speed
    if g.paddle.x - g.paddle.size < 0 {
        g.paddle.x = g.paddle.size
    }
    if g.paddle.x + g.paddle.size > WinWidth {
        g.paddle.x = WinWidth - g.paddle.size
    }
}
fn (g mut Game) move_ball() {
    g.ball.x += g.ball.dx
    g.ball.y += g.ball.dy
    if g.ball.x + g.ball.radius > WinWidth && g.ball.dx > 0 {
        g.ball.x = WinWidth - g.ball.radius
        g.ball.dx *= -1
    }
    if g.ball.x - g.ball.radius < 0 && g.ball.dx < 0 {
        g.ball.x = g.ball.radius
        g.ball.dx *= -1
    }
    if g.ball.y + g.ball.radius > WinHeight && g.ball.dy > 0 {
        println('Ball fell through. You died.')
        g.ball.y = 0
        g.ball.x = rand.next(WinWidth)
        //g.ball.y = WinHeight - g.ball.radius
        //g.ball.dy *= -1
    }
    if g.ball.y - g.ball.radius < 0 && g.ball.dy < 0 {
        g.ball.y = g.ball.radius
        g.ball.dy *= -1
    }

    if  g.ball.y + g.ball.radius > g.paddle.y &&
        iabs(g.ball.x - g.paddle.x) < g.paddle.size &&
        g.ball.dy > 0
    {
        if 1.0 * iabs(g.ball.x - g.paddle.x) > (0.6 * g.paddle.size) {
            println('paddle edge hit')
            g.ball.dx *= -1
        }else{
            println('paddle hit')
        }
        g.ball.y = g.paddle.y - g.ball.radius
        g.ball.dy *= -1
    }
    //g.ball.y += rand.next(4) - 2
    //g.ball.x += rand.next(4) - 2
}

fn iabs(a int) int {
    if a >= 0 {
        return a
    }
    return -a
}

fn (g mut Game) delete_broken_bricks() {
    //ptodo('delete_broken_bricks')
}

fn (g mut Game) print_state() {
    mut old_frames := g.frames
    mut fps := 0
    for {
        if(g.quit){
            break
        }
        fps = g.frames - old_frames
        g.fps = fps
        old_frames = g.frames
        println(' frame: ${g.frames:6d} | fps: ${fps:02d} | game.ball: ${g.ball.x:4d} ${g.ball.y:4d} ${g.ball.dx:2d} ${g.ball.dy:2d} | game.paddle: ${g.paddle.x:3d} ${g.paddle.y:3d}')
        time.sleep_ms( 1000 )
    }
}

fn (g mut Game) draw_paddle() {
    g.gg.draw_image( g.paddle.x - g.paddle.size, g.paddle.y+g.paddle.height, 2*g.paddle.size, - g.paddle.height, g.paddle.image )
}

fn (g mut Game) draw_ball() {
    g.gg.draw_image( g.ball.x - g.ball.radius, g.ball.y+g.ball.radius, 2*g.ball.radius, -2*g.ball.radius, g.ball.image )
}

fn (g mut Game) draw_bricks() {
    //ptodo('draw_bricks')
}

fn (g mut Game) draw_brick(i int, j int) {
    //ptodo('draw_brick $i $j')
}

fn (g mut Game) draw_stats() {
    g.ft.draw_text(3,3, 'fps: $g.fps', g.text_config)
    g.ft.draw_text(3,20, 'f: $g.frames', g.text_config)
}

const (
    KEY_UP = 0
    KEY_DOWN = 1
    KEY_REPEAT = 2
)
fn key_down(wnd voidptr, key int, code int, action, mods int) {
    if  action == KEY_DOWN {
        mut g := &Game(glfw.get_window_user_pointer(wnd))
        switch key {
        case glfw.KEY_ESCAPE:
            g.quit = true
        case glfw.KeyLeft:
            g.start_moving_paddle(true, false)
        case glfw.KeyRight:
            g.start_moving_paddle(false, true)
        case glfw.KeyUp:
            g.start_moving_paddle(false, false)
        }
        //println('key: $key | action: $action | mods: $mods')
    }
}

fn (g mut Game) start_moving_paddle(le bool, ri bool) {
    g.moves.right = ri
    g.moves.left  = le
}


fn (g mut Game) draw() {
    g.draw_bricks()
    g.draw_paddle()
    g.draw_ball()
    g.draw_stats()
}

////////////////////////////////////////////////////////////

fn main() {

    glfw.init()
    mut game := &Game{
                      ft: 0
                      text_config: 0
                      gg: gg.new_context(
                                         gg.Cfg {
                                                 width: WinWidth
                                                 height: WinHeight
                                                 use_ortho: true
                                                 create_window: true
                                                 window_title: 'V Breakout'
                                                 window_user_ptr: game
                                                 })
                      }
    game.gg.window.set_user_ptr(game)
    game.gg.window.onkeydown(key_down)
    gg.init()

    // Show transparent PNGs:
    gl.enable(GL_BLEND)
    C.glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)    
           
    // Try to load font
	game.ft = freetype.new_context(gg.Cfg{
			                              width: WinWidth
			                              height: WinHeight
			                              use_ortho: true
			                              font_size: 18
		                                  }, 1)
	if game.ft != 0 {
	   // if font loaded, define default font color etc..
	   game.text_config = &gx.TextCfg{
			                          align:gx.ALIGN_LEFT
			                          size:12
			                          color:gx.rgb(0, 0, 170)
		                              }
	}
           
    game.init_game()
    go game.run()
    go game.print_state()
    
    for {
        if( game.gg.window.should_close() || game.quit ) {
            break
        }
        gl.clear()
        gl.clear_color(22, 80, 120, 255)
        game.draw()
        game.gg.window.swap_buffers()
        glfw.poll_events()
        //glfw.wait_events()
    }

    println('Have a nice day.')
}
