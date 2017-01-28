#? stdtmpl
#
#import strutils, future
#from ../db import Episode
#
#
#proc renderNotes(notes: seq[string]): string =
#  result = ""
#  if len(notes) > 0:
Shownotes:
<ul class="notes">
#    for note in notes:
	<li>$note</li>
#    end for
</ul>
#  end if
#end proc
#
#proc renderTags(tags: seq[string]): string =
#  result = ""
#  const tagLink = """<a href="/episodes/tag/$#">$#</a>"""
<div class="tags">
	${lc[tagLink % [tag, tag] | (tag <- tags), string].join(", ")}
</div>
#end proc
#
#proc renderGuest(guest: string): string =
#  result = ""
#  if not guest.isNilOrEmpty:
<a href="/episodes/guest/$guest" class="guest">with $guest</a>
#  end if
#end proc
#
#proc renderDetailedEpisodeBanner*(episode: Episode): string =
#  result = ""
<!-- Banner -->
	<section id="banner">
		<header>
			<h2>
				<a href="/episode/latest">$episode.title</a>
				${renderGuest(episode.guest)}
			</h2>
			$episode.code
			<div class="tagline">
#  for paragraph in episode.tagline:
				<p>$paragraph</p>
#  end for
			</div>
			${renderNotes(episode.notes)}
			${renderTags(episode.tags)}
		</header>
	</section>
#end proc
#
#proc renderEpisodeTile*(episode: Episode): string =
#  result = ""
<div class="6u 12u(mobile)">
	<section class="box">
		<a href="#" class="image featured"><img src="images/pic02.png" alt="" /></a>
		<header>
			<h3>$episode.title</h3>
			<h4>${renderGuest(episode.guest)}</h4>
		</header>
#  for paragraph in episode.tagline:
		<p>$paragraph</p>
#  end for
		<footer>
			<a href="/episode/$episode.id" class="button alt">Listen</a>
		</footer>
	</section>
</div>
#end proc
