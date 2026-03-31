with teste as (
	select	top 100
			b.name,
			convert(varchar(11), b.date, 103) [date],
			replace(u.AboutMe, '', 'N/A') AboutMe,
			isnull(u.Age, datediff(year, CreationDate, getdate())) age,
			convert(varchar(10), u.CreationDate, 103) CreationDate,
			upper(left(u.DisplayName, 1)) + lower(substring(u.DisplayName, 2, len(u.DisplayName))) displayName, -- primeira letra maiúscula e o restante minúsculo
			u.DownVotes,
			convert(varchar(10), u.LastAccessDate, 103) LastAccessDate,
			u.Location,
			u.Reputation,
			u.UpVotes,
			u.Views
	from	Badges b
	join	Users u
	on		u.Id = b.UserId
)

select	*
from	teste
order	by DownVotes desc