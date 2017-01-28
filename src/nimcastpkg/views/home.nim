#? stdtmpl
#
#from ../db import Episode
#import main, blocks
#
#
#proc renderEpisodeTiles(episodes: seq[Episode]): string =
#  result = ""
#  if len(episodes) > 1:
<!-- Portfolio -->
	<section>
		<header class="major">
			<h2>Episodes</h2>
		</header>
		<div class="row">
#    for episode in episodes[1..high(episodes)]:
			${renderEpisodeTile(episode)}
#    end for
		</div>
	</section>
#  end if
#end proc
#
#proc renderHome*(episodes: seq[Episode]): string =
#  result = ""
			<!-- Header -->
				<div id="header-wrapper">
					<div id="header">

						<!-- Logo -->
							<h1>The Nim Lang Podcast</h1>
#  if len(episodes) > 0:
							${renderDetailedEpisodeBanner(episodes[0])}
#  else:
							<p>Nothing to see here yet.</p>
#  end if
					</div>
				</div>
#  if len(episodes) > 1:
			<!-- Main -->
				<div id="main-wrapper">
					<div class="container">
						<div class="row">
							<div class="12u">
								${renderEpisodeTiles(episodes)}
							</div>
						</div>
					</div>
				</div>
# end if
# result = renderMain result
#end proc
