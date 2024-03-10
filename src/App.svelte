<script lang="ts">
  import Papa from "papaparse";
  import { onMount } from "svelte";
  import html2canvas from 'html2canvas';
  import LayoutGrid, { Cell } from "@smui/layout-grid/styled";
  import { Player, Hls } from "@vime/svelte";
  import Card, {
    Content as CardContent,
    Media,
    MediaContent,
  } from "@smui/card/styled";

  import Drawer, {
    AppContent,
    Content,
    Header,
    Title,
  } from "@smui/drawer/styled";
  import List, { Item, Text } from "@smui/list/styled";
  import Button from "@smui/button/styled";
  import Switch from '@smui/switch/styled';
  import FormField from '@smui/form-field/styled';
  import ImageList, {
    Item as ImageItem,
    Image,
    Label,
  } from "@smui/image-list/styled";
  import Textfield from "@smui/textfield/styled";
  import IconButton from "@smui/icon-button/styled";
  import Slider from "@smui/slider/styled";
  import TabBar from "@smui/tab-bar/styled";
  import Tab from "@smui/tab/styled";
  import { get, writable } from "svelte/store";
  import { games } from "./store.js";
  import TopAppBar, {
    Row,
    Section,
    Title as AppBarTitle,
  } from "@smui/top-app-bar/styled";
  import Select, { Option } from '@smui/select/styled';
  import LazyImageLoader from "./lib/components/LazyImageLoader.svelte";

  let regions = [
    {
      name: "All",
      key: "ALL",
    },
    {
      name: "North America",
      key: "NA",
    },
    {
      name: "Europe",
      key: "EU",
    },
    {
      name: "Japan",
      key: "JPN",
    },
    {
      name: "Asia",
      key: "ASIA",
    },
    {
      name: "Taiwan/Hong Kong/China",
      key: "CHT",
    },
    {
      name: "Korea",
      key: "KOR",
    },
  ];

  let regionValue = 'ALL';
  let publisherValue = 'All';
  let limprintValue = 'None';
  let publishers = [{
    name: "All",
    key: "All",
  }];

  let limprints = [
    {
      name: "None",
      key: "None",
    },
    {
      name: "Limited Run Games",
      key: "LRG",
    },
    {
      name: "Super Rare Games",
      key: "SuRG",
    },
    {
      name: "Super Rare Games Shorts",
      key: "Shorts",
    },
    {
      name: "Strictly Limited Games",
      key: "SLG",
    },
    {
      name: "Red Art Games",
      key: "RAG",
    },
    {
      name: "B-Side Games",
      key: "BSG",
    },
    {
      name: "EastAsiaSoft",
      key: "EAS",
    },
    {
      name: "PixelHeart",
      key: "PXH",
    },
    {
      name: "Premium Edition Games",
      key: "PEG",
    },
    {
      name: "1Print Games",
      key: "1PG",
    },
  ];

  $: load = false;

  let switchView = false;
  let hide = true;
  let switchCartView = false;
  let switchSpineView = true;
  let onlyShowInside = false;
  let nintendoData = writable({});
  let sliderValue = 22;
  const hlsConfig = {};
  function convertHexToUni(value: string) {
    return value.replace(/\\x([0-9a-f]{1,4})/gi, function (m, c0) {
      return "\\u" + ("0000" + c0).slice(-4);
    });
  }

  let intersectionObserver;

  function ensureIntersectionObserver() {
    if (intersectionObserver) return;
    intersectionObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        const eventName = entry.isIntersecting ? 'enterViewport' : 'exitViewport';
        entry.target.dispatchEvent(new CustomEvent(eventName));
      });
    });
  }

  function viewport(element) {
    ensureIntersectionObserver();

    intersectionObserver.observe(element);

    return {
      destroy() {
        intersectionObserver.unobserve(element);
      }
    }
  }

  let totalCount = 0;
  let open = false;
  let mainPage = true;
  let active = "";
  let activeTab = "Info";
  let searchValue = "";
  let originalGames = [];
  let frontStyle = "";
  let backStyle = "";
  let spineStyle = "";
  let backgroundImageStyle = "";
  let titleids = [];

  onMount(async () => {
    const urlResult = new URLSearchParams(window.location.search);
    if (urlResult.has("code")) {
      hide = true;
    } else { 
      hide = false;
    }
    fetch("../list.csv")
      .then((response) => response.text())
      .then((data) => {
        let gamesArray = Papa.parse(data).data;
        gamesArray.shift();
        gamesArray.pop();
        totalCount = gamesArray.length;
        originalGames = gamesArray;
        games.set(gamesArray);
        const tempPublishers = originalGames.map((i) => {
          return i[5]
        })

        tempPublishers.sort().unshift("All")

        publishers = [...new Set(tempPublishers)].map((i) => {
          return {
            name: i,
            key: i,
          }
        })

        fetch(
          "https://raw.githubusercontent.com/julesontheroad/titledb/master/ninshop.json"
        )
          .then((response) => response.text())
          .then((data) => {
            nintendoData.set(JSON.parse(data));

            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.has("code")) {
              const activeCode = urlParams.get("code");
              let found = $games.find((v) => {
                return v[1] == activeCode;
              });
              setActive(found[1], found[2]);
            }
          })
          .catch((error) => {
            console.log(error);
            return [];
          });
      })
      .catch((error) => {
        console.log(error);
        return [];
      });
  });

  function markMainPage() {
    open = false;
    backgroundImageStyle = "";
    active = "";
    title = "Switch Cabinet";
    mainPage = true;
  }

  function screenshot() {
    html2canvas(document.querySelector("#book"), {
      foreignObjectRendering: true,
      removeContainer: false,
      windowWidth: 600,
      windowHeight: 600,
      useCORS: true,
      backgroundColor: null,
      allowTaint: true,
      scale: 10,
    }).then(canvas => {
      saveAs(canvas.toDataURL(), 'file-name.png');
    });
  }

  function saveAs(uri, filename) {
    var link = document.createElement('a');
    if (typeof link.download === 'string') {
      link.href = uri;
      link.download = filename;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    } else {
      window.open(uri);
    }
  }

  let title = "Switch Cabinet";

  $: document.title = title;

  $: if (limprintValue != "None") {
    let tempGames = []
    originalGames.filter(
        (item) => item[0].toLowerCase().indexOf(searchValue.toLowerCase()) !== -1 && item[6] == limprintValue
    ).forEach((item) => {
        tempGames.push([
          `${item[0]} [#${item[7]}]`,
          item[1],
          item[2],
          item[3],
          item[4],
          item[5],
          item[6],
          item[7],
        ])
    })
    games.set(
      tempGames.sort((a,b) => a[7] - b[7])
    );
    totalCount = get(games).length
  } else {
    if (regionValue == "ALL") {
    if (publisherValue == "All") {
        if (onlyShowInside) {
          games.set(
            originalGames.filter(
            (item) => (item[0].toLowerCase().indexOf(searchValue.toLowerCase()) !== -1  && item[3] === 'true')
            )
          );
          totalCount = get(games).length
        } else {
          games.set(
            originalGames.filter(
              (item) => item[0].toLowerCase().indexOf(searchValue.toLowerCase()) !== -1
            )
          );
          totalCount = get(games).length
        }
      } else {
        if (onlyShowInside) {
          games.set(
            originalGames.filter(
            (item) => (item[0].toLowerCase().indexOf(searchValue.toLowerCase()) !== -1  && item[3] === 'true') && item[5] == publisherValue
            )
          );
          totalCount = get(games).length
        } else {
          games.set(
            originalGames.filter(
              (item) => item[0].toLowerCase().indexOf(searchValue.toLowerCase()) !== -1 && item[5] == publisherValue
            )
          );
          totalCount = get(games).length
        }
      }
    } else {
      if (publisherValue == "All") {
          if (onlyShowInside) {
            games.set(
              originalGames.filter(
              (item) => (item[0].toLowerCase().indexOf(searchValue.toLowerCase()) !== -1  && item[3] === 'true') && item[4] == regionValue
              )
            );
            totalCount = get(games).length
          } else {
            games.set(
              originalGames.filter(
                (item) => item[0].toLowerCase().indexOf(searchValue.toLowerCase()) !== -1 && item[4] == regionValue
              )
            );
            totalCount = get(games).length
          }
        } else {
          if (onlyShowInside) {
            games.set(
              originalGames.filter(
              (item) => (item[0].toLowerCase().indexOf(searchValue.toLowerCase()) !== -1  && item[3] === 'true') && (item[4] == regionValue && item[5] == publisherValue)
              )
            );
            totalCount = get(games).length
          } else {
            games.set(
              originalGames.filter(
                (item) => item[0].toLowerCase().indexOf(searchValue.toLowerCase()) !== -1 && (item[4] == regionValue && item[5] == publisherValue)
              )
            );
            totalCount = get(games).length
          }
        }
      }
      }

  //function toggleInside(e) {
  //  if (onlyShowInside) {
  //    games.set(
  //      originalGames.filter(
  //        (item) => (item[0].toLowerCase().indexOf(searchValue.toLowerCase()) !== -1  && item[3] === 'true')
  //      )
  //    );
  //    totalCount = get(games).length
  //  } else {
  //    games.set(
  //      originalGames.filter(
  //        (item) =>
  //          item[0].toLowerCase().indexOf(searchValue.toLowerCase()) !== -1
  //      )
  //    );
  //    totalCount = get(games).length
  //  }
  //}

  let base_url = "https://cdn.switch-images-julio.com/file/switch-images-julio";
  //let base_url = "http://localhost:5000/images";

  function setActive(value: string, titleId: string) {
    activeTab = "Info";
    sliderValue = 22;
    titleids = titleId.split("|");
    title = originalGames.find((v) => {
      return v[1] == value;
    })[0];
    open = true;
    active = value;
    mainPage = false;
    if (titleids.length >= 1) {
      backgroundImageStyle = `
        background:
        linear-gradient(
          rgba(0, 0, 0, 0.45), 
          rgba(0, 0, 0, 0.45)
        ), url("${$nintendoData[titleids[0]]?.bannerUrl}");
        background-size:cover;
      `;
    }

    frontStyle = `
      background-image: linear-gradient(90deg, rgba(255, 255, 255, 0) 0%, rgba(255, 255, 255, 0.25) 25%, rgba(0, 0, 0, 0.15) 50%, rgba(255, 255, 255, 0) 100%), url("${base_url}/_resized/${value}/insert.png");
    `;

    backStyle = `
      background-image: linear-gradient(90deg, rgba(255, 255, 255, 0) 0%, rgba(255, 255, 255, 0.25) 25%, rgba(0, 0, 0, 0.15) 50%, rgba(255, 255, 255, 0) 100%), url("${base_url}/_resized/${value}/insert.png");
    `;

    spineStyle = `
      background-image: linear-gradient(90deg, rgba(255, 255, 255, 0) 0%, rgba(255, 255, 255, 0.25) 25%, rgba(0, 0, 0, 0.15) 50%, rgba(255, 255, 255, 0) 100%), url("${base_url}/_resized/${value}/spine.png");
      background-position: -400% 100%, right top, center top, left top; background-size: 1000% 200%, auto 100%, auto 100%, auto 100%; transform: rotateY(-90deg) translateX(-24px);
    `;

    let found = $games.find((v) => {
      return v[1] == value;
    });
    window.history.pushState(
      value,
      found[0],
      `/file/switch-images-julio/display/index.html?code=${value}`
      //`/index.html?code=${value}`
    );
  }
</script>

<div class="drawer-container">
  <Drawer variant="dismissible" bind:open>
    <Header>
      <Title>Switch Games: #{totalCount}</Title>
    </Header>
    <Content>
      <Button
        style="min-width: 250px;"
        variant="raised"
        on:click={() => markMainPage()}
      >
        <Label>Main Page</Label>
      </Button>
      <Textfield
        bind:value={searchValue}
        label="Search"
        style="min-width: 250px;"
      />
      <FormField>
        <Switch disabled={limprintValue != "None"} bind:checked={onlyShowInside} />
        <span slot="label">Show Only Games with Inside Art</span>
      </FormField>
      <FormField>
          <Select 
            bind:value={regionValue}
            disabled={limprintValue != "None"}
            key={(region) => `${region ? region.key : ''}`}
            label="Select Cart Region">
            {#each regions as region}
              <Option value={region.key}>{region.name}</Option>
            {/each}
          </Select>
      </FormField>
      <FormField>
          <Select 
            bind:value={publisherValue}
            key={(publisher) => `${publisher ? publisher.key : ''}`}
            disabled={limprintValue != "None"}
            label="Select Publisher">
            {#each publishers as publisher}
              <Option value={publisher.key}>{publisher.name}</Option>
            {/each}
          </Select>
      </FormField>
      <FormField>
          <Select 
            bind:value={limprintValue}
            key={(limprint) => `${limprint ? limprint.key : ''}`}
            label="LimPrint List">
            {#each limprints as limprint}
              <Option value={limprint.key}>{limprint.name}</Option>
            {/each}
          </Select>
      </FormField>
      <List style="height: 350px;">
        {#each $games as game}
          <Item
            href="javascript:void(0)"
            on:click={() => setActive(game[1], game[2])}
            activated={active === game[1]}
          >
            <Text>{game[0]}</Text>
          </Item>
        {/each}
      </List>
    </Content>
  </Drawer>
  <AppContent class="app-content" style={backgroundImageStyle}>
    {#if mainPage && !hide}
      <ImageList>
        <TopAppBar variant="static">
          <Row>
            <Section>
              <IconButton class="material-icons" on:click={() => (open = !open)}
                >menu</IconButton
              >
              <AppBarTitle>Switch Cabinet</AppBarTitle>
              <IconButton
                class="material-icons"
                on:click={() => {
                  switchCartView = false
                  switchView = !switchView
                }}
                >{#if !switchView}view_module{:else}view_column{/if}</IconButton
              >
              <IconButton
                class="material-icons"
                on:click={() => {
                  switchView = false
                  switchCartView = !switchCartView
                }}
                >{#if !switchCartView}style{:else}view_column{/if}</IconButton
              >
              {#if !switchView && !switchCartView}
                <IconButton
                  class="material-icons"
                  on:click={() => (switchSpineView = !switchSpineView)}
                  >autorenew</IconButton
                >
              {/if}

              <Label>All games individually scanned by me(discord: @juliosueiras)</Label>
                
            </Section>
          </Row>
        </TopAppBar>
        {#each $games as game}
          {#if switchView}
            <ImageItem
              style="width: 253.4px; height: 400px; cursor: pointer;"
              class="zoom"
            >
              <Image
                src="{base_url}/_resized/{game[1]}/front.png"
                alt={game[0]}
                style="height: 100%;"
                on:click={() => setActive(game[1], game[2])}
              />
            </ImageItem>
          {:else if switchCartView}
            {#if !game[1].includes("_S")}
              <ImageItem
                style="width: 70px; height: 100px; cursor: pointer;"
                class="zoom"
                >
                <Image
                src="{base_url}/{game[1]}/cart-label.png"
                  alt={game[0]}
                  style="height: 100%;"
                  on:click={() => setActive(game[1], game[2])}
                  />
              </ImageItem>
            {/if}
          {:else}
            <ImageItem
              style={switchSpineView
                ? "width: 24px; height: 400px;"
                : "width: 400px; height: 24px;"}
              class="zoom"
            >
              <LazyImageLoader
                src="{base_url}/_resized/{game[1]}/spine.png"
                alt={game[0]}
                style={switchSpineView
                  ? "height: 100%;"
                  : "width: 24px; height: 400px; transform: rotate(270deg); transform-origin: 12px 12px;"}
                on:click={() => setActive(game[1], game[2])}
              />
            </ImageItem>
          {/if}
        {/each}
      </ImageList>

    {:else}
      <TabBar
        style="background-color: white;"
        tabs={[
          "Info",
          "3D Box",
          "Front",
          "Back",
          "Spine",
          "Insert",
          "Inside",
          "Cart",
          "Cart Label",
        ]}
        let:tab
        bind:active={activeTab}
      >
        <Tab {tab}>
          <Label>{tab}</Label>
        </Tab>
      </TabBar>
      {#if activeTab == "3D Box"}
        <main class="main-content">
          <div id="book" class="stage">
            <div
              class="book_group"
              style="transform: rotateY({((sliderValue * 0.01) / 2) * 360}deg);"
            >
              <div
                on:click={() => (activeTab = "Back")}
                class="book_back"
                style={backStyle}
              >
                <div class="book_back-before" />
                <div class="book_back-after" />
              </div>
              <div
                on:click={() => (activeTab = "Front")}
                class="book_front"
                style={frontStyle}
              >
                <div
                  on:click={() => (activeTab = "Spine")}
                  class="book_front-before"
                  style={spineStyle}
                />
                <div class="book_front_trim">
                  <img alt="switch-case" />
                </div>
                <div class="book_front-after" />
              </div>
            </div>
            <img 
              style="visibility: visible; position: absolute; width: 70px; height: 100px; top: 50%; left: 60%;" src="{base_url}/{active}/cart-label.png" />
          </div>
          <Slider
            style="flex-grow: 1; width: 300px;"
            bind:value={sliderValue}
          />
        </main>
        <Button style="min-width: 250px;"
                variant="raised"
                on:click={() => screenshot()}
                >
                <Label>Download</Label>
        </Button>
      {:else if activeTab == "Info"}
        <div style="overflow: scroll; height: 93.5%;">
          {#each titleids as titleid}
            <LayoutGrid>
              {#if $nintendoData[titleid]}
                <Cell>
                  <Card>
                    <CardContent>
                      <img
                        style="width: 60px; height: 60px; border: 2px solid #000;"
                        src={$nintendoData[titleid].iconUrl}
                      />
                      <h3>
                        {$nintendoData[titleid].title
                          ? JSON.parse(
                              convertHexToUni(
                                JSON.stringify(
                                  $nintendoData[titleid].title
                                ).replace("\\\\", "\\")
                              )
                            )
                          : $nintendoData[titleid].name}
                      </h3>
                      <h3>
                        <a href={$nintendoData[titleid].url}
                          >Nintendo.com Link</a
                        >
                      </h3>
                      <h4>Description:</h4>
                      <p style="overflow: scroll; height: 200px;">
                        {$nintendoData[titleid].description}
                      </p>
                    </CardContent>
                  </Card>
                </Cell>
                {#if $nintendoData[titleid].video}
                  {#each $nintendoData[titleid].video as video, i}
                    <Cell>
                      <Card>
                        <Media aspectRatio="16x9">
                          <MediaContent>
                            <Player controls>
                              <Hls version="latest" config={hlsConfig}>
                                <source
                                  data-src={video.split("/").length != 9
                                    ? video.replace("Legacy%20Videos/", "")
                                    : video}
                                  type="application/x-mpegURL"
                                />
                              </Hls>
                            </Player>
                          </MediaContent>
                        </Media>
                      </Card>
                    </Cell>
                  {/each}
                {/if}
              {/if}
            </LayoutGrid>
          {/each}
        </div>
      {:else if activeTab == "Front"}
        <a
        href="{base_url}/{active}/front.png"
          ><img
            class="switch-image"
            alt="front image"
            src="{base_url}/_resized/{active}/front.png"
          /></a
        >
      {:else if activeTab == "Back"}
        <a
        href="{base_url}/{active}/back.png"
          ><img
            class="switch-image"
            alt="back image"
            src="{base_url}/_resized/{active}/back.png"
          /></a
        >
      {:else if activeTab == "Spine"}
        <a
        href="{base_url}/{active}/spine.png"
          ><img
            class="switch-spine-image"
            alt="spine image"
            src="{base_url}/_resized/{active}/spine.png"
          /></a
        >
      {:else if activeTab == "Insert"}
        <a
        href="{base_url}/{active}/insert.png"
          ><img
            class="switch-large-image"
            alt="insert image"
            src="{base_url}/_resized/{active}/insert.png"
          /></a
        >
      {:else if activeTab == "Inside"}
        <a
        href="{base_url}/{active}/inside.png"
          ><img
            class="switch-large-image"
            alt="inside image"
            src="{base_url}/_resized/{active}/inside.png"
          /></a
        >
      {:else if activeTab == "Cart"}
        <a
        href="{base_url}/{active}/cart.png"
          ><img
            class="switch-cart-image"
            alt="cart image"
            src="{base_url}/_resized/{active}/cart.png"
          /></a
        >
      {:else if activeTab == "Cart Label"}
        <a
        href="{base_url}/{active}/cart-label.png"
          ><img
            class="switch-cart-image"
            alt="cart-label image"
            src="{base_url}/_resized/{active}/cart-label.png"
          /></a
        >
      {/if}
    {/if}
  </AppContent>
</div>

<style>
  :global(html) {
    height: 100%;
    background: linear-gradient(rgba(0, 0, 0, 0.45), rgba(0, 0, 0, 0.45)),
      url("https://www.designyourway.net/blog/wp-content/uploads/2018/09/wood-_texture1584-scaled.jpg");
  }
  :global(body) {
    margin: 0px;
    height: 100%;
  }
  .switch-image {
    position: relative;
    visibility: visible;
    padding: 50px;
    width: 244px;
    height: 400px;
  }

  .switch-cart-image {
    position: relative;
    visibility: visible;
    padding: 50px;
    width: 250px;
    height: 400px;
  }

  .switch-large-image {
    position: relative;
    visibility: visible;
    padding: 50px;
    width: 512px;
    height: 400px;
  }

  :global(.zoom:hover) {
    transform: scale(
      1.3
    ); /* (150% zoom - Note: if the zoom is too large, it will go outside of the viewport) */
    z-index: 100000;
    margin: 0px 0 0 0px;
    box-shadow: 0 0 0 1px #fff;
  }

  .switch-spine-image {
    position: relative;
    visibility: visible;
    padding: 50px;
    width: 24px;
    height: 400px;
  }

  .drawer-container {
    position: relative;
    display: flex;
    height: 100%;
    max-width: 100%;
  }

  * :global(.app-content) {
    flex: auto;
    position: relative;
    flex-grow: 1;
  }

  .main-content {
    padding: 16px;
    box-sizing: border-box;
  }

  :global(.book_front_trim:hover) {
    box-shadow: inset 0px 0px 0px 2px #000;
  }

  :global(.book_front-before:hover) {
    box-shadow: inset 0px 0px 0px 2px #000;
  }

  :global(.book_back:hover) {
    box-shadow: inset 0px 0px 0px 2px #000;
  }
</style>
