local cjson = require'cjson'
local glue = require'glue'
local lfs = require'lfs'

local function list_repos(user)
	local i = 1
	local repos = {}
	while true do
		local s = glue.readpipe('wget -qO- --no-check-certificate '..
			'https://api.github.com/users/'..user..'/repos?page='..i)
		local t = cjson.decode(s)
		if #t == 0 then
			break
		end
		for i,repo in ipairs(t) do
			repos[#repos+1] = repo.name
		end
		i = i + 1
	end
	return repos
end

local function pull_repo(user, repo)
	local dir0 = lfs.currentdir()
	lfs.mkdir(user)
	assert(lfs.chdir(user))
	if lfs.attributes(repo, 'mode') ~= 'directory' then
		glue.readpipe('git clone git@github.com:'..user..'/'..repo)
	else
		assert(lfs.chdir(repo))
		glue.readpipe('git pull')
	end
	assert(lfs.chdir(dir0))
end

for i,user in ipairs{'capr', 'luapower'} do
	for i,repo in ipairs(list_repos(user)) do
		pull_repo(user, repo)
	end
end
