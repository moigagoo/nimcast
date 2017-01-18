#? stdtmpl
#
#import strutils
#import future
#import ../db
#
#proc renderNotes(notes: seq[string]): string =
#  result = ""
#  if len(notes) == 0:
#    return
#  end if
									<ul class="notes">
#  for note in notes:
										<li>$note</li>
#  end for
									</ul>
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
#proc renderLatestEpisodeBanner(latestEpisode: Episode): string =
#  result = ""
#  var guestSuffix: string = ""
#  if not latestEpisode.guest.isNilOrEmpty:
#    guestSuffix = """ <a href="/episodes/guest/$#" class="guest">with $#</a>""" % [latestEpisode.guest, latestEpisode.guest]
#  end if
						<!-- Banner -->
							<section id="banner">
								<header>
									<h2><a href="/episode/latest">
										$latestEpisode.title
										$guestSuffix
									</a></h2>
									$latestEpisode.code
									<p class="tagline">$latestEpisode.tagline</p>
									${renderNotes(latestEpisode.notes)}
									${renderTags(latestEpisode.tags)}
								</header>
							</section>
#end proc
#
#proc renderEpisodeTile(episode: Episode): string =
#  result = ""
											<div class="4u 12u(mobile)">
												<section class="box">
													<a href="#" class="image featured"><img src="images/pic02.jpg" alt="" /></a>
													<header>
														<h3>$episode.title</h3>
													</header>
													<p>$episode.tagline</p>
													<footer>
														<a href="/episode/$episode.id" class="button alt">Listen</a>
													</footer>
												</section>
											</div>
#end proc
#
#proc renderEpisodes(episodes: seq[Episode]): string =
#  result = ""
#  if len(episodes) <= 1:
#    return
#  end if
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
#end proc
#
#proc renderHome*(episodes: seq[Episode]): string =
#  result = ""
<!DOCTYPE HTML>
<!--
	Dopetrope by HTML5 UP
	html5up.net | @ajlkn
	Free for personal and commercial use under the CCA 3.0 license (html5up.net/license)
-->
<html>
	<head>
		<title>The Nim Lang Podcast | Podcast about Nim programming language</title>
		<meta charset="utf-8" />
		<meta name="viewport" content="width=device-width, initial-scale=1" />
		<!--[if lte IE 8]><script src="assets/js/ie/html5shiv.js"></script><![endif]-->
		<link rel="stylesheet" href="assets/css/main.css" />
		<!--[if lte IE 8]><link rel="stylesheet" href="assets/css/ie8.css" /><![endif]-->
	</head>
	<body class="homepage">
		<div id="page-wrapper">

			<!-- Header -->
				<div id="header-wrapper">
					<div id="header">

						<!-- Logo -->
							<h1>The Nim Lang Podcast</h1>

						${renderLatestEpisodeBanner(episodes[0])}

					</div>
				</div>

			<!-- Main -->
				<div id="main-wrapper">
					<div class="container">
						<div class="row">
							<div class="12u">
								${renderEpisodes(episodes)}
							</div>
						</div>
					</div>
				</div>

		</div>

		<!-- Scripts -->
			<script src="assets/js/jquery.min.js"></script>
			<script src="assets/js/jquery.dropotron.min.js"></script>
			<script src="assets/js/skel.min.js"></script>
			<script src="assets/js/skel-viewport.min.js"></script>
			<script src="assets/js/util.js"></script>
			<!--[if lte IE 8]><script src="assets/js/ie/respond.min.js"></script><![endif]-->
			<script src="assets/js/main.js"></script>

	</body>
</html>
#end proc