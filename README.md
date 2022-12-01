# fastim

FastIM - hypercharge Incident Management Speed.

## Getting Started

an opinionated way of handling incidents.

## Roadmap

* ticket history viewer
  * visually highlights ticket status changes
  * shows how ticket flows from different teams.
  * translate german descriptions to english

* quick ticket related file creation
  * integration with notepad++
  * quickly create files

* ticket activity
  * records activity each day
  * filter activity done on each day. 
    (by maintaining history object that logs activity entries for each day,this
    is better than going through hundreds of active/archived tickets and 
    fetching target date's activity from there.)
* Persitent fields like SR No., ticket status etc., just to track the tickets'
  latest status (these don't get logged into history object)

## behaviours

* only fetch "tickets index" (this index should only contain a list of active
  and archived tickets) when performing a normal search, and then do an extended
  search lazily when requested. this improves the perforamance of searching.
* only fetch ticket related info like persistant fields and activity log lazily
  when opening the expander.
* closing the ticket's expander should perform a disk persistance operation
    


