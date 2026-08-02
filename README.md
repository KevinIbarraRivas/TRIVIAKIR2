<div>
    <a href="https://www.loom.com/share/3b50097220cc41209b61fae6ed819e8a">
    </a>
    <a href="https://www.loom.com/share/3b50097220cc41209b61fae6ed819e8a">
      <img style="max-width:300px;" src="https://cdn.loom.com/sessions/thumbnails/3b50097220cc41209b61fae6ed819e8a-3b99b7926ad6feba-full-play.gif#t=0.1">
    </a>
  </div>
  
# Trivia

An iOS trivia game that pulls real questions from the [Open Trivia Database API](https://opentdb.com/). Answer a round of questions, get feedback on each one, and see your score at the end. Built in Swift.

## Features

- Fetches live question data from the Open Trivia Database API
- Pick a category of questions to play
- Feedback on whether each answer was right before moving to the next question
- True/False questions show only two options
- Final score at the end of the round
- Reset pulls a fresh set of questions
- Loading state while questions are being fetched
- Decodes HTML entities so questions with special characters display correctly

## What I learned

The main challenge was fetching and parsing data from a remote API. Questions with special characters would come through formatted wrong at first — solving that meant properly decoding the HTML entities in the API response before displaying them.

## Running it

1. Clone the repo
2. Open `Trivia.xcodeproj` in Xcode
3. Build and run

## License

Apache 2.0 — see LICENSE for details.
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
