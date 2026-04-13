with teste as (
	select	top 100
			b.name,
			convert(varchar(11), b.date, 103) [date],
			replace(isnull(u.AboutMe, 'Lorem ipsum dolor sit amet, consectetur adipiscing elit...'), '', 'N/A') AboutMe,
			isnull(u.Age, datediff(year, CreationDate, getdate())) age,
			convert(varchar(10), u.CreationDate, 103) CreationDate,
			upper(left(u.DisplayName, 1)) + lower(substring(u.DisplayName, 2, len(u.DisplayName))) displayName, -- primeira letra maiúscula e o restante minúsculo
			convert(varchar(10), u.LastAccessDate, 103) LastAccessDate,
			u.Views,
			replace(isnull(u.Location, 'N/A'), '', 'N/A') Location,
			u.Reputation,
			u.DownVotes,
			u.UpVotes,
			soma_votos = u.UpVotes + u.DownVotes
	from	Badges b
	join	Users u
	on		u.Id = b.UserId
)

select	ROW_NUMBER() over (order by soma_votos desc) as id_seq,
		*
from	teste
order	by soma_votos desc

return

select	upper(left(name, 1)) + lower(SUBSTRING(name, 2, len(name))) name,
		count(*) qtd
from	Badges
--where	right(name, 1) = '8'
group	by name
order	by name

select	displayName,
		UpVotes
from	Users
where	YEAR(CreationDate) = 2008
and		UpVotes = (select max(UpVotes) from users)