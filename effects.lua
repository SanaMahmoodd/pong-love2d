-- Princess Sparkle Pong | Background, hearts, sparkle trail, magic hits.
-- No image or sound assets are needed.

local Effects = {}

Effects.colors = {
    background = {0.12, 0.07, 0.20},
    panel      = {0.18, 0.10, 0.29},
    pink       = {1.00, 0.51, 0.77},
    purple     = {0.72, 0.54, 1.00},
    lavender   = {0.87, 0.76, 1.00},
    cream      = {1.00, 0.94, 0.98}
}

local C = Effects.colors
local width, height = 800, 600
local stars, particles = {}, {}
local clock, trailTimer = 0, 0

function Effects.setColor(color, alpha)
    love.graphics.setColor(color[1], color[2], color[3], alpha or 1)
end

-- Five-point stars, drawn entirely with LÖVE graphics.
function Effects.drawStar(cx, cy, radius)
    local inner = radius * 0.43
    for i = 0, 4 do
        local a = -math.pi / 2 + i * math.pi * 2 / 5
        local left = a - math.pi / 5
        local right = a + math.pi / 5
        local tipX = cx + math.cos(a) * radius
        local tipY = cy + math.sin(a) * radius
        local leftX = cx + math.cos(left) * inner
        local leftY = cy + math.sin(left) * inner
        local rightX = cx + math.cos(right) * inner
        local rightY = cy + math.sin(right) * inner
        love.graphics.polygon("fill", cx, cy, leftX, leftY, tipX, tipY)
        love.graphics.polygon("fill", cx, cy, tipX, tipY, rightX, rightY)
    end
end

local function drawSparkle(x, y, size)
    love.graphics.setLineWidth(1.5)
    love.graphics.line(x - size, y, x + size, y)
    love.graphics.line(x, y - size, x, y + size)
    love.graphics.line(x - size * 0.45, y - size * 0.45,
                       x + size * 0.45, y + size * 0.45)
    love.graphics.line(x - size * 0.45, y + size * 0.45,
                       x + size * 0.45, y - size * 0.45)
end

-- A heart is the visible ball, but the main game uses its enclosing square
-- as the AABB hitbox. This preserves the original collision assignment.
function Effects.drawHeart(x, y, size, color, alpha)
    Effects.setColor(color, alpha)
    local radius = size * 0.25
    love.graphics.circle("fill", x + size * 0.30, y + size * 0.34, radius)
    love.graphics.circle("fill", x + size * 0.70, y + size * 0.34, radius)
    love.graphics.polygon("fill",
        x + size * 0.07, y + size * 0.36,
        x + size * 0.93, y + size * 0.36,
        x + size * 0.50, y + size * 0.96)
end

local function addParticle(x, y, vx, vy, life, size, color, kind)
    particles[#particles + 1] = {
        x = x, y = y, vx = vx, vy = vy,
        life = life, maxLife = life, size = size,
        color = color, kind = kind
    }
end

function Effects.init(w, h)
    width, height = w, h
    stars, particles = {}, {}
    clock, trailTimer = 0, 0

    -- Animated Stars: slow twinkling with tiny horizontal drifting.
    for i = 1, 65 do
        stars[i] = {
            x = math.random(18, width - 18),
            y = math.random(16, height - 16),
            size = math.random(2, 7),
            phase = math.random() * math.pi * 2,
            speed = 0.9 + math.random() * 2.5,
            type = (i % 4 == 0) and "star" or "sparkle"
        }
    end
end

function Effects.clearParticles()
    particles = {}
    trailTimer = 0
end

function Effects.resetTrail()
    trailTimer = 0
end

-- Sparkle Trail: glitter particles gently drift behind the moving heart.
function Effects.emitTrail(ball, dt)
    trailTimer = trailTimer + dt
    while trailTimer >= 0.035 do
        trailTimer = trailTimer - 0.035
        local cx = ball.x + ball.size / 2
        local cy = ball.y + ball.size / 2
        local direction = (ball.dx >= 0) and 1 or -1
        local color = (math.random(2) == 1) and C.pink or C.lavender
        addParticle(
            cx - direction * 12 + math.random(-4, 4),
            cy + math.random(-6, 6),
            math.random(-20, 20) - ball.dx * 0.07,
            math.random(-30, 30),
            0.28 + math.random() * 0.28,
            math.random(2, 4),
            color,
            "dot"
        )
    end
end

-- Magic Hit: particle burst when the heart touches a paddle or wall.
function Effects.magicHit(x, y, mainColor)
    for i = 1, 20 do
        local angle = (i / 20) * math.pi * 2 + (math.random() - 0.5) * 0.24
        local speed = math.random(65, 180)
        local color = (i % 3 == 0) and C.cream or mainColor
        addParticle(x, y,
            math.cos(angle) * speed,
            math.sin(angle) * speed,
            0.35 + math.random() * 0.34,
            math.random(2, 5),
            color,
            (i % 3 == 0) and "spark" or "dot"
        )
    end
end

function Effects.update(dt)
    clock = clock + dt
    for i = #particles, 1, -1 do
        local p = particles[i]
        p.life = p.life - dt
        if p.life <= 0 then
            table.remove(particles, i)
        else
            p.x = p.x + p.vx * dt
            p.y = p.y + p.vy * dt
            p.vx = p.vx * (1 - 1.3 * dt)
            p.vy = p.vy * (1 - 1.3 * dt)
        end
    end
end

function Effects.drawParticles()
    for _, p in ipairs(particles) do
        local fade = p.life / p.maxLife
        Effects.setColor(p.color, fade * 0.9)
        if p.kind == "spark" then
            drawSparkle(p.x, p.y, p.size * fade)
        else
            love.graphics.circle("fill", p.x, p.y, p.size * fade)
        end
    end
end

function Effects.drawBackground()
    Effects.setColor(C.background)
    love.graphics.rectangle("fill", 0, 0, width, height)

    -- Subtle purple bands and animated pink/lavender stars.
    love.graphics.setColor(0.34, 0.20, 0.52, 0.10)
    love.graphics.rectangle("fill", 0, 0, width, 105)
    love.graphics.rectangle("fill", 0, height - 95, width, 95)

    for _, s in ipairs(stars) do
        local twinkle = 0.5 + 0.5 * math.sin(clock * s.speed + s.phase)
        local alpha = 0.15 + 0.60 * twinkle
        local drift = math.sin(clock * 0.5 + s.phase) * 1.4
        Effects.setColor((s.type == "star") and C.pink or C.lavender, alpha)
        if s.type == "star" then
            Effects.drawStar(s.x + drift, s.y, s.size)
        else
            drawSparkle(s.x + drift, s.y, s.size * (0.5 + 0.5 * twinkle))
        end
    end
end

return Effects
